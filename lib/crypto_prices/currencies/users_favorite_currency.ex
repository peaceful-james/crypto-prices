defmodule Crypto.Currencies.FavoriteCurrency do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "favorite_currencies" do
    belongs_to :user, Crypto.Accounts.User
    belongs_to :currency, Crypto.Currencies.Currency

    many_to_many :favorite_currencies, Crypto.Currencies.Currency,
      join_through: Crypto.Currencies.FavoriteCurrency
  end

  def changeset(favorite_currency, params) do
    favorite_currency
    |> cast(params, [:user_id, :currency_id])
    |> unsafe_validate_unique([:user_id, :currency_id], Crypto.Repo)
  end
end
