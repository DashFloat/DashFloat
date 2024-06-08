defmodule DashFloat.Identity.Emails.UpdateEmailInstructionsEmail do
  @moduledoc """
  Email containing instructions on how to reset a user's account
  email.
  """

  import Swoosh.Email

  alias DashFloat.Identity.Schemas.User

  @spec call(user :: User.t(), url :: binary()) :: Swoosh.Email.t()
  def call(user, url) do
    body = message_body(user, url)

    new()
    |> to(user.email)
    |> from({"DashFloat", "no-reply@dashfloat.com"})
    |> subject("Update Email Instructions")
    |> text_body(body)
  end

  defp message_body(user, url) do
    """
    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """
  end
end
