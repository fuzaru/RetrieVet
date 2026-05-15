defmodule RetrievetWeb.PageControllerTest do
  use RetrievetWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Welcome to RetrieVet"
  end
end
