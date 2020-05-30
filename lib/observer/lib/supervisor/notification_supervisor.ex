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
end
