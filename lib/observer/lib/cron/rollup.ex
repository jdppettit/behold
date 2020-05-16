defmodule Observer.Cron.Rollup do
  use GenServer

  require Logger

  alias Behold.Models.Value
  alias Behold.Models.Check
  alias Observer.Common.Notification

  @default_threshold 3

  def start_link(%{id: id} = check) do
    GenServer.start_link(
      __MODULE__,
      check,
      name: String.to_atom("#{id}-rollup")
    )
  end

  def init(%{interval: interval} = check) do
    Logger.debug("#{__MODULE__}: Initializing gen server for rollup on check #{check.id} with interval #{interval*3}")
    Process.send_after(self(), :rollup, 1_000)
    {:ok, %{check: check}}
  end

  def handle_info(:rollup, %{check: %{interval: interval}} = check) do
    Logger.debug("#{__MODULE__}: Running rollup logic on check #{check.check.id}")
    do_rollup(check.check)
    Process.send_after(self(), :rollup, interval)
    {:noreply, check}
  end

  def do_rollup(%{id: id} = check) do
    with {:ok, values} <- Value.get_recent_values_by_check_id(id),
         {:ok, alerted?} <- is_alerted?(values),
         {:ok, translated_alerted_state} <- translate_alerted(alerted?)
    do
      Logger.debug("#{__MODULE__}: Rollup finished, updating check #{id} to #{translated_alerted_state}")
      :ok = Check.update_check_state(check, translated_alerted_state)
      Notification.maybe_send_notification(check, translated_alerted_state)
    else
      error ->
        Logger.error("#{__MODULE__}: Rollup error: #{inspect(error)}")
    end
  end

  def is_alerted?(values, threshold \\ @default_threshold) do
    non_ok_count = values
    |> Enum.filter(fn v ->
      v.value == :critical
    end)
    {:ok, length(non_ok_count) == threshold}
  end

  def translate_alerted(true), do: {:ok, :critical}
  def translate_alerted(false), do: {:ok, :nominal}
end
