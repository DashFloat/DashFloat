defmodule DashFloat.Repo do
  use Ecto.Repo,
    otp_app: :dash_float,
    adapter: Ecto.Adapters.Postgres
end
