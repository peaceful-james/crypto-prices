defmodule CryptoWeb.CurrencyComponent do
  use Phoenix.Component

  def show(assigns) do
    Phoenix.View.render(CryptoWeb.CurrencyView, "currency-component.html", assigns)
  end
end
