defmodule Neverland.Repo do
  use Ecto.Repo,
    otp_app: :neverland,
    adapter: Ecto.Adapters.Postgres
end
