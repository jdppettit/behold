defmodule Observer.Common.AlertFramework do
  use GenServer
  require Logger

  defmacro __using__(opts) do
    type = Keyword.get(opts, :type, "Unknown")

    quote do
      def start_link(_opts) do
        Logger.debug("#{__MODULE__}: Starting #{type} alert process")
        GenServer.start_link(__MODULE__, :ok, name: name(type))
      end

      def init(:ok) do
        {:ok, nil}
      end

      def handle_call(:notification, alert) do
        case do_notification?(alert) do
          true ->
            do_notification(alert)
          false ->
            nil
        end
      end

      def name(type) do
        String.to_atom("#{type}-notification")
      end
    end
  end
end
