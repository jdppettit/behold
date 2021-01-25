defmodule Observer.Cron.Scheduler do
  use GenServer

  @interval 60_000

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: :scheduler)
  end

  def init(:ok) do
    Process.send_after(self(), :fire_check, 1_000)
    {:ok, nil}
  end

  def handle_info(:fire_check, state) do
    Observer.Supervisor.SchedulerSupervisor.schedule_checks
    Observer.Supervisor.SchedulerSupervisor.schedule_rollups
    Observer.Supervisor.NotificationSupervisor.schedule_notifications
    Process.send_after(self(), :fire_check, @interval)
    {:noreply, nil}
  end
end
