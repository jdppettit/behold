defmodule BeholdWeb.PageController do
  use BeholdWeb, :controller

  def index(conn, _params) do
    Observer.TestCheck.start_link()
    render conn, "index.html"
  end
end
