defmodule Crypto.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # TODO @peaceful-james don't start coinbase worker in test env
    children = [
      Crypto.Repo,
      CryptoWeb.Telemetry,
      {Phoenix.PubSub, name: Crypto.PubSub},
      %{
        id: Crypto.Coinbase.Worker,
        start: {Crypto.Coinbase.Worker, :start_link, []}
      },
      CryptoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Crypto.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CryptoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
