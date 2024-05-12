defmodule DashFloat.Identity.Repositories.UserRepository do
  @moduledoc """
  Repository for the `User` schema in the `Identity` context.
  """

  use DashFloat, :repository

  alias DashFloat.Identity.Schemas.User

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_email(user :: User.t(), attrs :: map()) :: Ecto.Changeset.t()
  def change_email(user, attrs) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  @spec change_registration(user :: User.t(), attrs :: map()) :: Ecto.Changeset.t()
  def change_registration(%User{} = user, attrs) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

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

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  @spec get_by_email_and_password(email :: String.t(), password :: binary()) :: User.t() | nil
  def get_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)

    if User.valid_password?(user, password), do: user
  end

  @doc """
  Registers a user.

  ## Examples

      iex> register(%{field: value})
      {:ok, %User{}}

      iex> register(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec register(attrs :: map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def register(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end
end
