defmodule BeholdWeb.ChecksController do
  use BeholdWeb, :controller

  def create(conn, %{
    "type" => type,
    "target" => target,
    "interval" => interval,
    "value" => value
  } = _params) do
    with {:ok, _type} <- validate_type(type)
    do
      conn
    else
      conn
    end
  end

  def validate_type(type) do
    case type do
      "http" ->
        {:ok, "http"}
      "ping" ->
        {:ok, "ping"}
      "http_json" ->
        {:ok, "http_json"}
      _ ->
        {:error, :bad_type}
    end
  end
end
