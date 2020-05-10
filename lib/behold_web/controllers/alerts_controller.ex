defmodule BeholdWeb.AlertsController do
  use BeholdWeb, :controller

  require Logger

  alias Behold.Models.Alert

  def create(conn, params) do
    with {:ok, _type} <- validate_type(get_key(params, "type")),
         {:ok, _check_id} <- extract_check_id(params),
         {:ok, mapped_params} <- extract_params(params),
         {:ok, changeset} <- Alert.create_changeset(mapped_params),
         {:ok, model} <- Alert.insert(changeset)
    do
      conn
      |> render("alert_created.json", alert: model)
    else
      {:error, :missing_check_id} ->
        conn
        |> put_status(400)
        |> render("invalid_parameters.json", message: "Missing check ID")
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

  def update(conn, params) do
    with {:ok, _type} <- validate_type(get_key(params, "type")),
         {:ok, mapped_params} <- extract_params(params),
         {:ok, alert_id} <- extract_id(params),
         {:ok, _check_id} <- extract_check_id(params),
         {:ok, alert_model} <- Alert.get_by_id(alert_id),
         {:ok, changeset} <- Alert.create_changeset(alert_model, mapped_params),
         {:ok, updated_model} <- Alert.update(changeset)
    do
      conn
      |> render("alert_updated.json", alert: updated_model)
    else
      {:error, :missing_check_id} ->
        conn
        |> put_status(400)
        |> render("invalid_parameters.json", message: "Missing check ID")
      {:error, :missing_id} ->
        conn
        |> put_status(400)
        |> render("invalid_parameters.json", message: "Missing alert ID")
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

  def delete(conn, %{"id" => id} = _params) do
    with {:ok, _} <- Alert.delete_by_id(id) do
      conn
      |> render("alert_deleted.json")
    else
      {:ok, :not_found} ->
        conn
        |> put_status(404)
        |> render("not_found.json", message: "Alert not found")
      {:error, :database_error} ->
        conn
        |> put_status(500)
        |> render("server_error.json", message: "Unexpected database error")
      _ ->
        conn
        |> put_status(500)
        |> render("server_error.json", message: "Unexpected server error")
    end
  end

  def get_all(conn, _params) do
    conn
    |> render("alerts.json", alerts: Alert.get_all_valid_alerts)
  end

  def validate_type(type) do
    case type in AlertType.__valid_values__() do
      true ->
        {:ok, type}
      false ->
        {:error, :bad_type}
    end
  end

  def extract_params(params) do
    {:ok,
      %{
        target: get_key(params, "target"),
        type: get_key(params, "type"),
        interval: get_key(params, "interval"),
        check_id: get_key(params, "check_id")
      } |> filter_nil_keys
    }
  end

  def extract_id(params) do
    id = get_key(params, "id")
    if is_nil(id) do
      {:error, :missing_id}
    else
      {:ok, id}
    end
  end

  def extract_check_id(params) do
    id = get_key(params, "check_id")
    if is_nil(id) do
      {:error, :missing_check_id}
    else
      {:ok, id}
    end
  end

  def get_key(map, key) do
    case Map.fetch(map, key) do
      {:ok, value} ->
        value
      _ ->
        nil
    end
  end

  def filter_nil_keys(map) do
    keys = Map.keys(map)
    nil_keys = keys
    |> Enum.reduce([], fn key, acc ->
      if is_nil(get_key(map, key)) do
        [key | acc]
      else
        acc
      end
    end)
    Map.drop(map, nil_keys)
  end
end
