defmodule Observer.Common.CheckFramework do
  use GenServer
  require Logger

  defmacro __using__(opts) do
    name = Keyword.get(opts, :name, "Unkown")
    
    quote do
      def start_link(%{type: type, id: id} = check) do
        Logger.debug("#{__MODULE__}: Starting #{type} check for check #{id}")
        GenServer.start_link(__MODULE__, check, name: name(check))
      end

      def init(%{interval: interval} = check) do
        Process.send_after(self(), :fire_check, 1_000)
        {:ok, %{check: check}}
      end

      def handle_info(:fire_check, %{check: %{interval: interval}} = check) do
        do_check(check.check)
        Process.send_after(self(), :fire_check, interval)
        {:noreply, %{check: check.check}}
      end

      def name(%{type: type, id: id} = _check) do
        String.to_atom("#{id}-#{Atom.to_string(type)}")
      end
    end
  end
end
