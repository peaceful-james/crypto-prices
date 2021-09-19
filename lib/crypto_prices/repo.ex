defmodule Crypto.Repo do
  use Ecto.Repo,
    otp_app: :crypto_prices,
    adapter: Ecto.Adapters.Postgres
end
