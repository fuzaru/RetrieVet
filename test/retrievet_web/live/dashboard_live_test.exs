defmodule RetrievetWeb.DashboardLiveTest do
  use RetrievetWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the dashboard landing page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/dashboard")

    assert has_element?(view, "#dashboard-header")
    assert has_element?(view, "#dashboard-stats")
    assert has_element?(view, "#dashboard-queue")
    assert has_element?(view, "#dashboard-actions")
  end
end
