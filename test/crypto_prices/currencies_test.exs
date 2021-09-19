defmodule Crypto.CurrenciesTest do
  use Crypto.DataCase

  alias Crypto.Currencies

  describe "currencies" do
    alias Crypto.Currencies.{Currency, FavoriteCurrency}

    import Crypto.{AccountsFixtures, CurrenciesFixtures}

    @invalid_attrs %{current_price: nil, name: nil, priced_at: nil}

    test "list_currencies/0 returns all currencies" do
      currency = currency_fixture()
      assert currency in Currencies.list_currencies()
    end

    test "get_currency!/1 returns the currency with given id" do
      currency = currency_fixture()
      assert Currencies.get_currency!(currency.id) == currency
    end

    test "create_currency/1 with valid data creates a currency" do
      valid_attrs = %{
        current_price: "120.5",
        name: :DOGE,
        priced_at: ~N[2021-09-17 01:39:00]
      }

      assert {:ok, %Currency{} = currency} = Currencies.create_currency(valid_attrs)
      assert currency.current_price == Decimal.new("120.5")
      assert currency.name == :DOGE
      assert currency.priced_at == ~N[2021-09-17 01:39:00]
    end

    test "create_currency/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Currencies.create_currency(@invalid_attrs)
    end

    test "update_currency/2 with valid data updates the currency" do
      currency = currency_fixture()

      update_attrs = %{
        current_price: "456.7",
        name: :BTC,
        priced_at: ~N[2021-09-18 01:39:00]
      }

      assert {:ok, %Currency{} = currency} = Currencies.update_currency(currency, update_attrs)
      assert currency.current_price == Decimal.new("456.7")
      assert currency.name == :BTC
      assert currency.priced_at == ~N[2021-09-18 01:39:00]
    end

    test "update_currency/2 with invalid data returns error changeset" do
      currency = currency_fixture()
      assert {:error, %Ecto.Changeset{}} = Currencies.update_currency(currency, @invalid_attrs)
      assert currency == Currencies.get_currency!(currency.id)
    end

    test "delete_currency/1 deletes the currency" do
      currency = currency_fixture()
      assert {:ok, %Currency{}} = Currencies.delete_currency(currency)
      assert_raise Ecto.NoResultsError, fn -> Currencies.get_currency!(currency.id) end
    end

    test "change_currency/1 returns a currency changeset" do
      currency = currency_fixture()
      assert %Ecto.Changeset{} = Currencies.change_currency(currency)
    end

    test "create_favorite_currency creates a favorite currency for a user" do
      user = user_fixture()
      currency = currency_fixture()
      valid_attrs = %{user_id: user.id, currency_id: currency.id}

      assert {:ok, %FavoriteCurrency{} = favorite_currency} =
               Currencies.create_favorite_currency(valid_attrs)

      assert favorite_currency.user_id == user.id
      assert favorite_currency.currency_id == currency.id
    end

    test "create_favorite_currency forbids duplicate currency + user" do
      user = user_fixture()
      currency = currency_fixture()
      valid_attrs = %{user_id: user.id, currency_id: currency.id}
      assert {:ok, %FavoriteCurrency{}} = Currencies.create_favorite_currency(valid_attrs)

      assert {:error, %Ecto.Changeset{} = changeset} =
               Currencies.create_favorite_currency(valid_attrs)

      assert [user_id: {"has already been taken", _}] = changeset.errors
    end

    test "delete_favorite_currency deletes a favorite currency for a user" do
      user = user_fixture()
      currency = currency_fixture()
      valid_attrs = %{user_id: user.id, currency_id: currency.id}

      assert {:ok, %FavoriteCurrency{} = favorite_currency} =
               Currencies.create_favorite_currency(valid_attrs)

      assert {:ok, _deleted} = Currencies.delete_favorite_currency(favorite_currency)
    end
  end
end
