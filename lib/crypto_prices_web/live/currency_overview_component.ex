defmodule CryptoWeb.CurrencyOverviewComponent do
  use Phoenix.Component

  def show(assigns) do
    ~H"""
    <div>
      <h3 class="text-gray-900 font-bold text-2xl tracking-tight m-0"><%= currency_label(assigns.currency.name) %></h3>
      <p class="font-normal text-gray-700 m-0">$<%= assigns.currency.current_price %></p>
    </div>
    """
  end

  defp currency_label(:BTC), do: "Bitcoin"
  defp currency_label(:ETH), do: "Ethereum"
  defp currency_label(:DOGE), do: "Dogecoin"
end
