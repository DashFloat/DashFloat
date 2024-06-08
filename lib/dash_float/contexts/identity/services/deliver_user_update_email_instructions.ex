defmodule DashFloat.Identity.Services.DeliverUserUpdateEmailInstructions do
  @moduledoc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """

  alias DashFloat.Identity.Emails.UpdateEmailInstructionsEmail
  alias DashFloat.Identity.Repositories.UserTokenRepository
  alias DashFloat.Identity.Schemas.User
  alias DashFloat.Identity.Schemas.UserToken
  alias DashFloat.Repo

  @spec call(user :: User.t(), current_email :: String.t(), update_email_url_fun :: (binary() -> binary())) :: {:ok, Swoosh.Email.t()} | {:error, atom()}
  def call(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))

    with {:ok, encoded_token} <- UserTokenRepository.create(user, "change:#{current_email}") do
      url = update_email_url_fun.(encoded_token)
      email = UpdateEmailInstructionsEmail.call(user, url)
    end
  end
end
