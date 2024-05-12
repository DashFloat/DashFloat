defmodule DashFloat.Identity.Repositories.UserRepositoryTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.IdentityFactory

  alias DashFloat.Identity.Repositories.UserRepository
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.TestHelpers.IdentityTestHelper

  describe "apply_email/3" do
    setup do
      password = "totally valid password"
      user = insert(:user, %{password: password})
      %{user: user, password: password}
    end

    test "requires email to change", %{user: user, password: password} do
      {:error, changeset} = UserRepository.apply_email(user, password, %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{user: user, password: password} do
      {:error, changeset} =
        UserRepository.apply_email(user, password, %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{user: user, password: password} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        UserRepository.apply_email(user, password, %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{user: user, password: password} do
      %{email: email} = insert(:user)

      {:error, changeset} = UserRepository.apply_email(user, password, %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        UserRepository.apply_email(user, "invalid", %{email: Faker.Internet.email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{user: user, password: password} do
      email = Faker.Internet.email()
      {:ok, user} = UserRepository.apply_email(user, password, %{email: email})
      assert user.email == email
      assert IdentityTestHelper.get_user!(user.id).email != email
    end
  end

  describe "change_email/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = UserRepository.change_email(%User{}, %{})
      assert changeset.required == [:email]
    end
  end

  describe "change_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = UserRepository.change_registration(%User{}, %{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = Faker.Internet.email()
      password = "valid password"

      changeset =
        UserRepository.change_registration(
          %User{},
          %{email: email, password: password}
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "get_by_email/1" do
    test "with non-existing email returns nil" do
      assert UserRepository.get_by_email("unknown@example.com") == nil
    end

    test "with existing email returns user" do
      %{id: id} = user = insert(:user)

      assert %User{id: ^id} = UserRepository.get_by_email(user.email)
    end
  end

  describe "get_by_email_and_password/2" do
    test "with non-existing email returns nil" do
      assert UserRepository.get_by_email_and_password("unknown@example.com", "hello world!") == nil
    end

    test "with existing email and invalid password returns nil" do
      user = insert(:user)
      assert UserRepository.get_by_email_and_password(user.email, "invalid") == nil
    end

    test "with existing email and valid password returns user" do
      password = "totally valid password"
      %{id: id} = user = insert(:user, %{password: password})

      assert %User{id: ^id} =
               UserRepository.get_by_email_and_password(user.email, password)
    end
  end

  describe "register/1" do
    test "with blank email and password returns error" do
      {:error, changeset} = UserRepository.register(%{})

      errors = errors_on(changeset)

      assert errors |> Map.keys() |> length() == 2
      assert errors.email == ["can't be blank"]
      assert errors.password == ["can't be blank"]
    end

    test "with invalid email and password returns error" do
      {:error, changeset} = UserRepository.register(%{email: "not valid", password: "not valid"})

      errors = errors_on(changeset)

      assert errors |> Map.keys() |> length() == 2
      assert errors.email == ["must have the @ sign and no spaces"]
      assert errors.password == ["should be at least 12 character(s)"]
    end

    test "with very long email returns error" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = UserRepository.register(%{email: "#{too_long}@example.com", password: "totally valid password"})

      errors = errors_on(changeset)

      assert errors |> Map.keys() |> length() == 1
      assert errors.email == ["should be at most 160 character(s)"]
    end

    test "with very long password returns error" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = UserRepository.register(%{email: Faker.Internet.email(), password: too_long})

      errors = errors_on(changeset)

      assert errors |> Map.keys() |> length() == 1
      assert errors.password == ["should be at most 72 character(s)"]
    end

    test "with taken email returns error" do
      %{email: email} = insert(:user)

      {:error, changeset} = UserRepository.register(%{email: email})
      errors = errors_on(changeset)

      assert errors |> Map.keys() |> length() == 2
      assert errors.email == ["has already been taken"]

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = UserRepository.register(%{email: String.upcase(email)})
      errors = errors_on(changeset)

      assert errors |> Map.keys() |> length() == 2
      assert errors.email == ["has already been taken"]
    end

    test "with valid data creates new user" do
      email = Faker.Internet.email()
      {:ok, user} = UserRepository.register(%{email: email, password: "some password"})

      assert user.email == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end
  end
end
