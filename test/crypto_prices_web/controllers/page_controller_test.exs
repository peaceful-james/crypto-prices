defmodule CryptoWeb.PageControllerTest do
  use CryptoWeb.ConnCase

  setup _ do
    start_supervised!(Crypto.Coinbase.Worker)
    :ok
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Crypto Live Price Tracker"
  end
end
