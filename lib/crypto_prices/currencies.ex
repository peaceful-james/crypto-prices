defmodule Crypto.Currencies do
  @moduledoc """
  The Currencies context.
  """

  import Ecto.Query, warn: false
  alias Crypto.Repo

  alias Crypto.Currencies.{Currency, FavoriteCurrency}

  @doc """
  Returns the list of currencies.

  ## Examples

      iex> list_currencies()
      [%Currency{}, ...]

  """
  def list_currencies do
    Repo.all(Currency)
  end

  @doc """
  Gets a single currency.

  Raises `Ecto.NoResultsError` if the Currency does not exist.

  ## Examples

      iex> get_currency!(123)
      %Currency{}

      iex> get_currency!(456)
      ** (Ecto.NoResultsError)

  """
  def get_currency!(id), do: Repo.get!(Currency, id)

  @doc """
  Gets a single currency by the given opts.

  Returns nil no Currency was found, or if more than one matched.

  ## Examples

  iex> get_currency_by(name: "BTC)
  %Currency{}

  iex> get_currency_by(name: "BAD_NAME")
  nil

  """
  def get_currency_by(opts), do: Repo.get_by(Currency, opts)
  def get_currency_by!(opts), do: Repo.get_by!(Currency, opts)

  @doc """
  Creates a currency.

  ## Examples

      iex> create_currency(%{field: value})
      {:ok, %Currency{}}

      iex> create_currency(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_currency(attrs \\ %{}) do
    %Currency{}
    |> Currency.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a currency.

  ## Examples

      iex> update_currency(currency, %{field: new_value})
      {:ok, %Currency{}}

      iex> update_currency(currency, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_currency(%Currency{} = currency, attrs) do
    currency
    |> Currency.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a currency.

  ## Examples

      iex> delete_currency(currency)
      {:ok, %Currency{}}

      iex> delete_currency(currency)
      {:error, %Ecto.Changeset{}}

  """
  def delete_currency(%Currency{} = currency) do
    Repo.delete(currency)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking currency changes.

  ## Examples

      iex> change_currency(currency)
      %Ecto.Changeset{data: %Currency{}}

  """
  def change_currency(%Currency{} = currency, attrs \\ %{}) do
    Currency.changeset(currency, attrs)
  end

  @favorite_totals_topic "favorite_totals"

  def create_favorite_currency(attrs) do
    case %FavoriteCurrency{}
         |> FavoriteCurrency.changeset(attrs)
         |> Repo.insert() do
      {:ok, favorite_currency} ->
        Phoenix.PubSub.broadcast(
          Crypto.PubSub,
          @favorite_totals_topic,
          {:favorite_totals, {:inc, favorite_currency.currency_id}}
        )

        {:ok, favorite_currency}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def delete_favorite_currency(%FavoriteCurrency{} = favorite_currency) do
    case Repo.delete(favorite_currency) do
      {:ok, favorite_currency} ->
        Phoenix.PubSub.broadcast(
          Crypto.PubSub,
          @favorite_totals_topic,
          {:favorite_totals, {:dec, favorite_currency.currency_id}}
        )

        {:ok, favorite_currency}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def toggle_favorite_currency(attrs) do
    case Repo.get_by(FavoriteCurrency, attrs) do
      nil -> {:created, create_favorite_currency(attrs)}
      favorite_currency -> {:deleted, delete_favorite_currency(favorite_currency)}
    end
  end

  def list_favorite_currency_ids_for_user(nil), do: []

  def list_favorite_currency_ids_for_user(%{id: user_id}) do
    FavoriteCurrency
    |> from()
    |> where(user_id: ^user_id)
    |> select([f], f.currency_id)
    |> Repo.all()
  end

  @doc """
  Returns a map with currency_id as key
  and total favorites as value.
  We do a join to ensure we account for all currencies,
  even those with no "favorite_currency" entries.
  """
  def get_favorite_currency_totals do
    Currency
    |> from(as: :currency)
    |> join(:left, [c], f in FavoriteCurrency, on: c.id == f.currency_id, as: :favorite_currency)
    |> group_by([currency: c], c.id)
    |> select([currency: c, favorite_currency: f], {c.id, count(f.id)})
    |> Repo.all()
    |> Enum.into(%{})
  end
end
