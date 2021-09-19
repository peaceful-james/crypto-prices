defmodule Crypto.Coinbase.Worker do
  use GenServer
  require Logger

  alias Crypto.Coinbase.CoinbaseService
  alias Crypto.Currencies
  alias Crypto.Currencies.Currency

  # TODO @peaceful-james consider only updating DB if price has changed
  # TODO @peaceful-james move DB job to task in context module

  @prices_topic "prices"
  @interval :timer.seconds(5)
  @currency "USD"
  @currency_names Ecto.Enum.values(Currency, :name)
  @default_coin_state %{current_price: "0.0", priced_at: NaiveDateTime.utc_now()}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    Logger.info(
      "Starting coinbase worker. Will fetch prices for #{inspect(@currency_names)} every #{@interval} seconds"
    )

    currencies_by_name =
      guaranteed_currencies_list()
      |> Enum.map(&{&1.name, &1})
      |> Enum.into(%{})

    Enum.each(@currency_names, &Process.send(self(), {:fetch_price, &1}, []))
    {:ok, currencies_by_name}
  end

  @impl true
  def handle_info({:fetch_price, name}, state) do
    state =
      case fetch_price(name) do
        {:ok, updated_currency} ->
          Phoenix.PubSub.broadcast(
            Crypto.PubSub,
            @prices_topic,
            {:updated_currency, updated_currency}
          )

          Map.put(state, name, updated_currency)

        _ ->
          state
      end

    Process.send_after(self(), {:fetch_price, name}, @interval)
    {:noreply, state}
  end

  @impl true
  def handle_call(:get_state, _, state) do
    {:reply, state, state}
  end

  defp fetch_price(name) do
    case CoinbaseService.get_price("#{name}-#{@currency}") do
      {:ok, {200, %{"data" => %{"amount" => amount}}}} ->
        # TODO @peaceful-james consider not re-getting from DB before updating (does anything else change this table?)
        Currencies.get_currency_by!(name: name)
        |> Currencies.update_currency(%{current_price: amount, priced_at: NaiveDateTime.utc_now()})

      response ->
        Logger.error(
          "Unable to fetch latest price for #{name}. Response from coinbase service: #{inspect(response, pretty: true)}"
        )

        {:error, nil}
    end
  end

  defp guaranteed_currencies_list() do
    currencies_in_db = Currencies.list_currencies()

    Enum.map(@currency_names, fn name ->
      case Enum.find(currencies_in_db, &(&1.name == name)) do
        nil ->
          {:ok, currency} =
            @default_coin_state |> Map.put(:name, name) |> Currencies.create_currency()

          currency

        currency ->
          currency
      end
    end)
  end
end
