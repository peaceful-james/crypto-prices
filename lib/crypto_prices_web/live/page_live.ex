defmodule CryptoWeb.PageLive do
  use CryptoWeb, :live_view
  alias Crypto.{Accounts, Coinbase, Currencies}

  @prices_topic "prices"
  @favorite_totals_topic "favorite_totals"

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Crypto.PubSub, @prices_topic)
      Phoenix.PubSub.subscribe(Crypto.PubSub, @favorite_totals_topic)
    end

    currencies = GenServer.call(Coinbase.Worker, :get_state)
    favorite_currency_totals = Currencies.get_favorite_currency_totals()

    socket =
      socket
      |> assign(%{
        currencies: currencies,
        favorite_currency_totals: favorite_currency_totals
      })
      |> assign_new(
        :current_user,
        fn -> Accounts.get_user_by_session_token(session["user_token"]) end
      )
      |> then(fn %{assigns: %{current_user: current_user}} = socket ->
        assign(
          socket,
          :favorite_currency_ids,
          Currencies.list_favorite_currency_ids_for_user(current_user)
        )
      end)

    {:ok, socket}
  end

  @impl true
  def handle_info(
        {:updated_currency, updated_currency},
        %{assigns: %{currencies: currencies}} = socket
      ) do
    {:noreply,
     assign(socket, :currencies, Map.put(currencies, updated_currency.name, updated_currency))}
  end

  @impl true
  def handle_info(
        {:favorite_totals, {inc_or_dec, currency_id}},
        %{assigns: %{favorite_currency_totals: favorite_currency_totals}} = socket
      ) do
    delta =
      case inc_or_dec do
        :inc -> 1
        :dec -> -1
      end

    {:noreply,
     assign(
       socket,
       :favorite_currency_totals,
       Map.update!(favorite_currency_totals, currency_id, &(&1 + delta))
     )}
  end

  @impl true
  def handle_event(
        "toggle-favorite",
        %{"id" => id},
        %{assigns: %{favorite_currency_ids: favorite_currency_ids, current_user: current_user}} =
          socket
      )
      when is_map(current_user) do
    case Currencies.toggle_favorite_currency(%{
           user_id: current_user.id,
           currency_id: id
         }) do
      {:created, {:ok, %{currency_id: currency_id}}} ->
        {:noreply, assign(socket, :favorite_currency_ids, [currency_id | favorite_currency_ids])}

      {:deleted, {:ok, %{currency_id: currency_id}}} ->
        {:noreply,
         assign(
           socket,
           :favorite_currency_ids,
           Enum.reject(favorite_currency_ids, &(&1 == currency_id))
         )}
    end
  end

  def handle_event("toggle-favorite", %{"id" => _id}, socket) do
    {:noreply, put_flash(socket, :info, "You need to be logged in to favorite coins")}
  end
end
