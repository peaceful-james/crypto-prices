defmodule Crypto.Repo.Migrations.CreateFavoriteCurrencies do
  use Ecto.Migration

  def change do
    create table(:favorite_currencies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      add :currency_id, references(:currencies, type: :binary_id, on_delete: :delete_all),
        null: false
    end

    create unique_index(:favorite_currencies, [:user_id, :currency_id])
  end
end
