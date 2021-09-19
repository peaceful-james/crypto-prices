defmodule Crypto.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Crypto.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CryptoWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @doc """
  The list of children to be started as part of the application.
  The children will be different in different environments.
  """
  @spec children() :: [:supervisor.child_spec() | {module, term} | module]
  def children do
    first_children = [
      Crypto.Repo,
      CryptoWeb.Telemetry,
      {Phoenix.PubSub, name: Crypto.PubSub}
    ]

    extra_children =
      case Application.get_env(:crypto_prices, :env) do
        :test ->
          []

        _ ->
          [
            %{
              id: Crypto.Coinbase.Worker,
              start: {Crypto.Coinbase.Worker, :start_link, []}
            }
          ]
      end

    last_children = [
      CryptoWeb.Endpoint
    ]

    first_children ++ extra_children ++ last_children
  end
end
