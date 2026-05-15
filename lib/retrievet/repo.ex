defmodule Retrievet.Repo do
  use Ecto.Repo,
    otp_app: :retrievet,
    adapter: Ecto.Adapters.Postgres
end
