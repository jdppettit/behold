defmodule Observer.Check.HTTP do
  use GenServer

  alias Observer.Common.HTTP

  def start_link(check) do
    GenServer.start_link(__MODULE__, check, name: String.to_atom("#{check.id}-#{Atom.to_string(check.type)}"))
  end

  def init(%{interval: interval} = check) do
    Process.send_after(self(), :fire_check, interval)
    {:ok, %{check: check}}
  end

  def handle_info(:fire_check, %{check: %{interval: interval}} = check) do
    do_check(check.check)
    Process.send_after(self(), :fire_check, interval)
    {:noreply, %{check: check.check}}
  end

  def do_check(%{value: value, target: target} = check) do
    HTTP.get(target, value)
  end
end
