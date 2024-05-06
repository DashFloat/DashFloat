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
end
