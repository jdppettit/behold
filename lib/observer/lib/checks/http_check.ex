defmodule Observer.Check.HTTP do
  use GenServer

  @interval 1_000

  def start_link(check) do
    GenServer.start_link(__MODULE__, check, name: String.to_atom("#{check.id}-#{Atom.to_string(check.type)}"))
  end

  def init(%{interval: interval} = check) do
    Process.send_after(self(), :fire_check, interval)
    {:ok, %{check: check}}
  end

  def handle_info(:fire_check, %{check: %{interval: interval}} = check) do
    IO.puts "check_http"
    Process.send_after(self(), :fire_check, interval)
    {:noreply, %{check: check.check}}
  end
end
