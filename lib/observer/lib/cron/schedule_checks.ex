defmodule Observer.Cron.ScheduleChecks do
  use GenServer

  #@interval 60_000
  @interval 5_000

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.send_after(self(), :fire_check, @interval)
    {:ok, nil}
  end

  def handle_info(:fire_check, state) do
    {:ok, checks} = Behold.Models.Check.get_all_valid_checks()
    schedule_checks(checks)
    Process.send_after(self(), :fire_check, @interval)
    {:noreply, nil}
  end

  defp schedule_checks(checks) do
    checks
    |> Enum.map(fn %{type: type} = check ->
      case type do
        :http ->
          if is_nil(Process.whereis(String.to_atom("#{check.id}-#{Atom.to_string(check.type)}"))) do
            Observer.Check.HTTP.start_link(Map.from_struct(check))
          end
        :ping ->
          if is_nil(Process.whereis(String.to_atom("#{check.id}-#{Atom.to_string(check.type)}"))) do
            Observer.Check.Ping.start_link(Map.from_struct(check))
          end
      end
    end)
  end
end
