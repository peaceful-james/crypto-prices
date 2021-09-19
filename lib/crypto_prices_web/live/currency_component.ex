defmodule CryptoWeb.CurrencyComponent do
  @moduledoc """
  A component for displaying a clickable coinbase currency with price and total favorites
  """
  use Phoenix.Component

  def show(assigns) do
    Phoenix.View.render(CryptoWeb.CurrencyView, "currency-component.html", assigns)
  end
end
