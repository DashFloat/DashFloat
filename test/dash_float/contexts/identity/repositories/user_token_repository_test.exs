defmodule DashFloat.Identity.Repositories.UserTokenRepositoryTest do
  use DashFloat.DataCase, async: true
  
  import DashFloat.Factories.IdentityFactory

  alias DashFloat.Identity.Repositories.UserTokenRepository

  describe "create/2" do
    test "with valid input returns an encoded token" do
      user = insert(:user)
    end
  end
end
