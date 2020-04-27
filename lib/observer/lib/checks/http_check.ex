defmodule Observer.Check.HTTP do
  use GenServer

  @interval 1_000

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.send_after(self(), :fire_check, @interval)
    {:ok, nil}
  end

  def handle_info(:fire_check, state) do
    IO.puts "foo"
    Process.send_after(self(), :fire_check, @interval)
    {:noreply, nil}
  end
end
