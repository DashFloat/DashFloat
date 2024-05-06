defmodule DashFloat.Identity.Repositories.UserRepository do
  @moduledoc """
  Repository for the `User` schema in the `Identity` context.
  """

  use DashFloat, :repository

  alias DashFloat.Identity.Schemas.User

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_by_email("foo@example.com")
      %User{}

      iex> get_by_email("unknown@example.com")
      nil

  """
  @spec get_by_email(email :: String.t()) :: User.t() | nil
  def get_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end
end
