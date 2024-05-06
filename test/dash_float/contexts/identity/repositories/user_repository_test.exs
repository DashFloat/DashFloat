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
end
