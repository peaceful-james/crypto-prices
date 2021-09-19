defmodule Crypto.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :crypto_prices

  @doc """
  Runs migrations on all configured repos
  """
  @spec migrate() :: [{:ok, term(), [atom()]} | {:error, term()}]
  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  @doc """
  Rolls the given repo back to the given version
  """
  @spec rollback(module(), binary()) :: {:ok, term(), [atom()]}
  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  @spec repos() :: [module()]
  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  @spec load_app :: :ok | {:error, term}
  defp load_app do
    Application.load(@app)
  end
end
