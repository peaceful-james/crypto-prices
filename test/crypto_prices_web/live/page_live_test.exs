defmodule CryptoWeb.PageLiveTest do
  use CryptoWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Crypto.Currencies.Currency

  describe "Authenticated Price Tracker" do
    setup [
      :start_coinbase_worker,
      :register_and_log_in_user
    ]

    test "displays logged in user's email", %{conn: conn, user: user} do
      {:ok, _price_tracker, html} = live(conn, Routes.price_tracker_path(conn, :index))
      assert html =~ user.email
    end

    test "displays prices for all currencies", %{conn: conn} do
      {:ok, price_tracker, _html} = live(conn, Routes.price_tracker_path(conn, :index))

      expected_label =
        &case &1 do
          :BTC -> "Bitcoin"
          :ETH -> "Ethereum"
          :DOGE -> "Dogecoin"
        end

      for name <- Ecto.Enum.values(Currency, :name) do
        currency_component =
          price_tracker
          |> element("#currency-component-#{name}")
          |> render()

        assert currency_component =~ expected_label.(name)
      end
    end
  end
end
