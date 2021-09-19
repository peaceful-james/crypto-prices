defmodule Crypto.Currencies.Currency do
  @moduledoc """
  A currency as fetched from Coinbase.
  The name is the coinbase "coin code" as an atom, e.g. :BTC
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "currencies" do
    field :current_price, :decimal
    field :name, Ecto.Enum, values: [:BTC, :ETH, :DOGE]
    field :priced_at, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [:name, :current_price, :priced_at])
    |> validate_required([:name, :current_price, :priced_at])
  end
end
