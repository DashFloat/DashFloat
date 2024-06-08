defmodule DashFloat.Identity.Repositories.UserTokenRepository do
  @moduledoc """
  Repository for the `UserToken` schema in the `Identity` context.
  """

  use DashFloat, :repository

  alias DashFloat.Identity.IdentityConstants
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Identity.Schemas.UserToken

  @doc """
  Creates a token and its hash to be delivered to external clients (user's
  email, api clients).

  The non-hashed token is sent to external clients while the hashed part is
  stored in the database. The original token cannot be reconstructed, which
  means anyone with read-only access to the database cannot directly use the
  token in the application to gain access. Furthermore, if the user changes
  their email in the system, the tokens sent to the previous email are no longer
  valid.

  Users can easily adapt the existing code to provide other types of delivery
  methods, for example, by phone numbers.

  ## Examples

      iex> create(user, "change:test@example.com")
      {:ok, "1234qwerasdfzxcv"}

      iex> create(invalid_user, "change:test@example.com")
      {:error, :invalid_user}

  """
  @spec create(user :: User.t(), context :: String.t()) :: {:ok, binary()} | {:error, :invalid_user}
  def create(%User{id: id, email: email}, context) do
    token = :crypto.strong_rand_bytes(IdentityConstants.rand_size())
    hashed_token = :crypto.hash(IdentityConstants.hash_algorithm(), token)

    Repo.insert!(%UserToken{
      token: hashed_token,
      context: context,
      sent_to: email,
      user_id: id
    })

    {:ok, Base.url_encode64(token, padding: false)}
  end

  def create(_user, _context), do: {:error, :invalid_user}
end
