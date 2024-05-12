defmodule DashFloat.Identity.Services.UpdateUserEmail do
  @moduledoc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """

  alias Ecto.Multi
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Identity.Schemas.UserToken
  alias DashFloat.Repo

  @spec call(user :: User.t(), token :: binary()) :: :ok | :error
  def call(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Multi.new()
    |> Multi.update(:user, changeset)
    |> Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end
end
