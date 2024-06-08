defmodule DashFloat.Identity.Emails.ConfirmationInstructionsEmail do
  @moduledoc """
  Email containing instructions on how to confirm a user's account.
  """

  import Swoosh.Email

  alias DashFloat.Identity.Schemas.User

  @spec call(user :: User.t(), url :: binary()) :: Swoosh.Email.t()
  def call(user, url) do
    body = message_body(user, url)

    new()
    |> to(user.email)
    |> from({"DashFloat", "no-reply@dashfloat.com"})
    |> subject("Confirmation Instructions")
    |> text_body(body)
  end

  defp message_body(user, url) do
    """
    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """
  end
end
