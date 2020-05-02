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
          if is_nil(Process.whereis(String.to_atom("#{check.id}-#{Atom.to_string(check.type)}"))) do
            DynamicSupervisor.start_child(__MODULE__, %{
              id: Observer.Check.HTTP,
              start: {Observer.Check.HTTP, :start_link, [Map.from_struct(check)]}
            })
          end
        :ping ->
          if is_nil(Process.whereis(String.to_atom("#{check.id}-#{Atom.to_string(check.type)}"))) do
            DynamicSupervisor.start_child(__MODULE__, %{
              id: Observer.Check.Ping,
              start: {Observer.Check.Ping, :start_link, [Map.from_struct(check)]}
            })
          end
      end
    end)
  end

  def schedule_rollups do
    Logger.debug("#{__MODULE__}: Running rollup checks")
    {:ok, checks} = Behold.Models.Check.get_all_valid_checks()
    checks
    |> Enum.map(fn %{type: type} = check ->
      if is_nil(Process.whereis(String.to_atom("#{check.id}-rollup"))) do
        DynamicSupervisor.start_child(__MODULE__, %{
          id: Observer.Cron.Rollup,
          start: {Observer.Cron.Rollup, :start_link, [Map.from_struct(check)]}
        })
      end
    end)
  end
end
