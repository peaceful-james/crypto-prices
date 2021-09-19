defmodule Crypto.Coinbase.CoinbaseService do
  alias Crypto.Quest

  @type dispatch_result :: {:ok, {scode :: integer(), any()}} | {:error, any()}
  defp default_q do
    %Quest{
      dispatcher: Quest.HTTPoisonDispatcher,
      request_encoding: :urlencoded,
      response_encoding: :json,
      headers: [],
      params: %{},
      base_url: "https://api.coinbase.com/v2/",
      destiny: "coinbase",
      adapter_options: [recv_timeout: 20_000]
    }
  end

  def client(client_opts \\ []) do
    client_opts
    |> Enum.into(default_q())
  end

  def http_req(req, options) do
    options
    |> Enum.into(req)
    |> Quest.dispatch()
  end

  @doc """
  Sends a HTTP request using the default Coinbase Quest struct
  """
  def default_http_req(options), do: http_req(client(), options)

  def get_price(coin, price_type \\ :spot) do
    default_http_req(path: "prices/#{coin}/#{price_type}")
  end
end
