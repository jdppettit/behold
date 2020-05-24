defmodule BeholdWeb.HealthController do
  use BeholdWeb, :controller

  require Logger

  def get(conn, _params) do
    with {:ok, raw_health_data} <- Observer.Supervisor.SchedulerSupervisor.health_data(),
         {:ok, enriched_health_data} <- enrich_health_data(raw_health_data)
    do
      conn
      |> render("health_data.json", health: enriched_health_data)
    else
      _ ->
        conn
        |> put_status(500)
        |> render("server_error.json", message: "Unexpected server error")
    end
  end

  def enrich_health_data(health_data) do
    check_all_good? = health_data.expected_count == get_running_count(health_data.check_processes)
    rollup_all_good? = health_data.expected_count == get_running_count(health_data.rollup_processes)
    {:ok, %{
      expected_process_count: health_data.expected_count,
      scheduler_alive: health_data.scheduler_alive,
      check_processes: %{
        alive_count: get_running_count(health_data.check_processes),
        total_count: health_data.expected_count,
        all_alive: check_all_good?,
        process_data: health_data.check_processes
      },
      rollup_processes: %{
        alive_count: get_running_count(health_data.rollup_processes),
        total_count: health_data.expected_count,
        all_alive: rollup_all_good?,
        process_data: health_data.rollup_processes    
      }
    }}
  end

  def get_running_count(process_list) do
    filtered_list = process_list 
    |> Enum.filter(fn process -> 
      process.status == "running"
    end)
    length(filtered_list)
  end
end