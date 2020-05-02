defmodule BeholdWeb.ChecksController do
  use BeholdWeb, :controller

  require Logger

  alias Behold.Models.Check

  def create(conn, %{
    "type" => type,
    "target" => target,
    "interval" => interval,
    "value" => value
  } = _params) do
    with {:ok, _type} <- validate_type(type),
         {:ok, changeset} <- Check.create_changeset(
            type,
            value,
            interval,
            target
         ),
         {:ok, model} <- Check.insert(changeset)
    do
      conn
      |> render("check_created.json", check: model)
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

  def get(conn, %{"id" => id} = _params) do
    with {:ok, model} <- Check.get_by_id(id) do
      conn
      |> render("check.json", check: model)
    else
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render("not_found.json", message: "Check not found")
      _ ->
        conn
        |> put_status(500)
        |> render("server_error.json", message: "Unexpected server error")
    end
  end

  def get_all(conn, _params) do
    with {:ok, models} <- Check.get_all_valid_checks() do
      conn
      |> render("checks.json", checks: models)
    else
      {:error, :not_found} ->
        conn
        |> put_status(404)
        |> render("not_found.json", message: "Check not found")
      _ ->
        conn
        |> put_status(500)
        |> render("server_error.json", message: "Unexpected server error")
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
