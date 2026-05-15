defmodule RetrievetWeb.PageController do
  use RetrievetWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
