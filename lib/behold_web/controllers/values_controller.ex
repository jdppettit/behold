defmodule BeholdWeb.ValuesController do
  use BeholdWeb, :controller

  require Logger

  alias Behold.Models.Value

  def get(conn, %{"check_id" => check_id} = _params) do
    with {:ok, values} <- Value.get_by_check_id(check_id) do
      conn
      |> render("values.json", values: values)
    else
      _ ->
        conn
        |> put_status(500)
        |> render("server_error.json", message: "Unexpected server error")
    end
  end
end