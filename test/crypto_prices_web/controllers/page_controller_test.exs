defmodule CryptoWeb.PageControllerTest do
  use CryptoWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Crypto Live Price Tracker"
  end
end
