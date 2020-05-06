defmodule BeholdWeb.AlertsController do
  use BeholdWeb, :controller

  require Logger

  alias Behold.Models.Alert

  @valid_types ["sms", "phone", "email", "webhook"]

  def create(conn, %{
    "type" => type,
    "target" => target,
    "interval" => interval,
    "check_id" => check_id
  } = _params) do
    with {:ok, _type} <- validate_type(type),
         {:ok, changeset} <- Alert.create_changeset(
            type,
            target,
            interval,
            check_id,
            nil
         ),
         {:ok, model} <- Alert.insert(changeset)
    do
      conn
      |> render("alert_created.json", alert: model)
    else
      {:error, :bad_type} ->
        conn
        |> put_status(400)
        |> render("bad_type.json", message: "Unexpected type provided")
      {:error, :database_error} ->
        conn
        |> put_status(500)
        |> render("server_error.json", message: "Unexpected database error")
      {:error, :changeset_invalid} ->
        conn
        |> put_status(400)
        |> render("invalid_parameters.json", message: "Invalid parameters provided")
      _ ->
        conn
        |> put_status(500)
        |> render("server_error.json", message: "Unexpected server error")
    end
  end

  defp validate_type(type) do
    {:ok, type in @valid_types}
  end
end
