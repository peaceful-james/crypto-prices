defmodule Crypto.CurrenciesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Crypto.Currencies` context.
  """

  @doc """
  Generate a currency.
  """
  def currency_fixture(attrs \\ %{}) do
    {:ok, currency} =
      attrs
      |> Enum.into(%{
        current_price: "120.5",
        name: :ETH,
        priced_at: ~N[2021-09-17 01:39:00]
      })
      |> Crypto.Currencies.create_currency()

    currency
  end
end
