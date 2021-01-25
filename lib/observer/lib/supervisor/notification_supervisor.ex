defmodule Observer.Supervisor.NotificationSupervisor do
  use DynamicSupervisor

  require Logger

  def start_link(_arg) do
    Logger.debug("#{__MODULE__}: NotificationSupervisor starting")
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init([
      strategy: :one_for_one,
      max_restarts: 1000,
      max_seconds: 5
    ])
  end

  def schedule_notifications do
    Logger.debug("#{__MODULE__}: Running notification checks")
    {:ok, checks} = Behold.Models.Check.get_all_valid_checks()
    checks
    |> Enum.map(fn check -> 
      DynamicSupervisor.start_child(__MODULE__, %{
        id: Observer.Cron.Notification,
        start: {Observer.Cron.Notification, :start_link, [Map.from_struct(check)]}
      })
    end)
  end
end
