defmodule Crypto.Repo.Migrations.CreateCurrencies do
  use Ecto.Migration

  def change do
    create table(:currencies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :text
      add :current_price, :decimal
      add :priced_at, :naive_datetime

      timestamps()
    end
  end
end
