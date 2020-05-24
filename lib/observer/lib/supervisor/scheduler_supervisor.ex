defmodule Observer.Supervisor.SchedulerSupervisor do
  use DynamicSupervisor

  require Logger

  def start_link(_arg) do
    Logger.debug("#{__MODULE__}: SchedulerSupervisor starting")
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
    DynamicSupervisor.start_child(__MODULE__, %{
      id: Observer.Cron.Scheduler,
      start: {Observer.Cron.Scheduler, :start_link, []}
    })
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def schedule_checks do
    Logger.debug("#{__MODULE__}: Running schedule checks")
    {:ok, checks} = Behold.Models.Check.get_all_valid_checks()
    checks
    |> Enum.map(fn %{type: type} = check ->
      case type do
        :http ->
          DynamicSupervisor.start_child(__MODULE__, %{
            id: Observer.Check.HTTP,
            start: {Observer.Check.HTTP, :start_link, [Map.from_struct(check)]}
          })
        :ping ->
          DynamicSupervisor.start_child(__MODULE__, %{
            id: Observer.Check.Ping,
            start: {Observer.Check.Ping, :start_link, [Map.from_struct(check)]}
          })
        :http_json ->
          DynamicSupervisor.start_child(__MODULE__, %{
            id: Observer.Check.JSON,
            start: {Observer.Check.JSON, :start_link, [Map.from_struct(check)]}
          })
        :http_json_comparison ->
          DynamicSupervisor.start_child(__MODULE__, %{
            id: Observer.Check.JSONComparison,
            start: {Observer.Check.JSONComparison, :start_link, [Map.from_struct(check)]}
          })
        :http_comparison ->
          DynamicSupervisor.start_child(__MODULE__, %{
            id: Observer.Check.HTTPComparison,
            start: {Observer.Check.HTTPComparison, :start_link, [Map.from_struct(check)]}
          })
        :dns ->
          DynamicSupervisor.start_child(__MODULE__, %{
            id: Observer.Check.DNS,
            start: {Observer.Check.DNS, :start_link, [Map.from_struct(check)]}
          })
      end
    end)
  end

  def get_child_by_name(name) do
    Process.whereis(String.to_atom(name))
  end

  def kill_child(name) do
    case Process.whereis(String.to_atom(name)) do
      pid when not is_nil(pid) ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)
        Logger.info("#{__MODULE__}: Terminating child #{name} / #{pid} because of update")
        {:ok, pid}
      nil ->
        {:error, name}
      error ->
        {:error, error}
    end
  end

  def health_data do
    {:ok, checks} = Behold.Models.Check.get_all_valid_checks()
    processes_expected = length(checks)

    check_processes_list = checks
    |> Enum.map(fn check -> 
      if not is_nil(get_child_by_name("#{check.id}-#{check.type}")) do
        %{id: check.id, status: "running", type: "check", name: "#{check.id}-#{check.type}"}
      else
        %{id: check.id, status: "not_running", type: "check", name: "#{check.id}-#{check.type}"}
      end
    end)

    rollup_processes_list = checks
    |> Enum.map(fn check -> 
      if not is_nil(get_child_by_name("#{check.id}-rollup")) do
        %{id: check.id, status: "running", type: "rollup", name: "#{check.id}-rollup"}
      else
        %{id: check.id, status: "not_running", type: "rollup", name: "#{check.id}-rollup"}
      end
    end) |> IO.inspect(label: "rollups")

    scheduler_alive? = if not is_nil(get_child_by_name("scheduler")) do
      true
    else
      false
    end

    {:ok, %{
      expected_count: processes_expected,
      check_processes: check_processes_list,
      rollup_processes: rollup_processes_list,
      scheduler_alive: scheduler_alive?
    }}
  end

  def schedule_rollups do
    Logger.debug("#{__MODULE__}: Running rollup checks")
    {:ok, checks} = Behold.Models.Check.get_all_valid_checks()
    checks
    |> Enum.map(fn %{type: type} = check ->
      DynamicSupervisor.start_child(__MODULE__, %{
        id: Observer.Cron.Rollup,
        start: {Observer.Cron.Rollup, :start_link, [Map.from_struct(check)]}
      })
    end)
  end
end
