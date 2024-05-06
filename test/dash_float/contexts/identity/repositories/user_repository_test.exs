defmodule DashFloat.Identity.Repositories.UserRepositoryTest do
  use DashFloat.DataCase, async: true

  import DashFloat.Factories.IdentityFactory

  alias DashFloat.Identity.Repositories.UserRepository
  alias DashFloat.Identity.Schemas.User

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
