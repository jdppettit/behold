defmodule BeholdWeb.ChecksController do
  use BeholdWeb, :controller

  require Logger

  alias Behold.Models.Check

  def create(conn, params) do
    with {:ok, _type} <- validate_type(get_key(params, "type")),
         {:ok, mapped_params} <- extract_params(params),
         {:ok, changeset} <- Check.create_changeset(mapped_params),
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

  def update(conn, params) do
    with {:ok, _type} <- validate_type(get_key(params, "type")),
         {:ok, mapped_params} <- extract_params(params),
         {:ok, check_id} <- extract_id(params),
         {:ok, check_model} <- Check.get_by_id(check_id),
         {:ok, changeset} <- Check.create_changeset(check_model, mapped_params),
         {:ok, updated_model} <- Check.update(changeset),
         {:ok, _type} <- possibly_kill_process(params, check_model)
    do
      conn
      |> render("check_updated.json", check: updated_model)
    else
      {:error, :missing_id} ->
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
      error ->
        Logger.error("#{__MODULE__}: update endpoint got unexpected error: #{inspect(error)}")
        conn
        |> put_status(500)
        |> render("server_error.json", message: "Unexpected server error")
    end
  end

  def delete(conn, %{"id" => id} = _params) do
    with {:ok, _} <- Check.delete_by_id(id) do
      conn
      |> render("check_deleted.json")
    else
      _ ->
        conn
        |> put_status(500)
        |> render("server_error.json", message: "Unexpected server error")
    end
  end

  def get(conn, %{"id" => id} = _params) do
    with {:ok, model} <- Check.get_by_id(id, :preload),
         {:ok, enriched_model} <- enrich_process_data(model)
    do
      conn
      |> render("check.json", check: enriched_model)
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
    with {:ok, models} <- Check.get_all_valid_checks(:preload) do
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
    case type in CheckTypes.__valid_values__() do
      true ->
        {:ok, type}
      false ->
        {:error, :bad_type}
    end
  end

  def extract_params(params) do
    {:ok,
      %{
        type: get_key(params, "type"),
        value: get_key(params, "value"),
        interval: get_key(params, "interval"),
        target: get_key(params, "target"),
        state: get_key(params, "state"),
        name: get_key(params, "name"),
        operation: get_key(params, "operation"),
        comparison: get_key(params, "comparison")
      } |> filter_nil_keys
    }
  end

  def possibly_kill_process(params, %{id: id, type: type} = model) do
    if Map.has_key?(params, :type) and not is_nil(Map.get(params, :type)) do
      Observer.Supervisor.SchedulerSupervisor.kill_child(String.to_atom("#{id}-#{Atom.to_string(type)}"))
    end
    {:ok, type}
  end

  def extract_id(params) do
    id = get_key(params, "id")
    if is_nil(id) do
      {:error, :missing_id}
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

  def enrich_process_data(model) do
    {rollup_running, _} = check_rollup_status(model)
    {check_running, _} = check_check_status(model)
    model = model
    |> Map.put(:processes, %{rollup_running: rollup_running, check_running: check_running})
    {:ok, model}
  end

  def check_rollup_status(%{id: id} = _model) do
    pid = Process.whereis(String.to_atom("#{id}-rollup"))
    {not is_nil(pid), pid}
  end

  def check_check_status(%{id: id, type: type} = _model) do
    pid = Process.whereis(String.to_atom("#{id}-#{type}"))
    {not is_nil(pid), pid}
  end 
end
