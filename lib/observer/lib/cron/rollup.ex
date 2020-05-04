defmodule Observer.Cron.Rollup do
  use GenServer

  require Logger

  alias Behold.Models.Value
  alias Behold.Models.Check

  @interval 180_000
  @default_threshold 3

  def start_link(%{id: id} = check) do
    GenServer.start_link(
      __MODULE__,
      check,
      name: String.to_atom("#{id}-rollup")
    )
  end

  def init(check) do
    Logger.debug("#{__MODULE__}: Initializing gen server for rollup on check #{check.id}")
    Process.send_after(self(), :rollup, @interval)
    {:ok, %{check: check}}
  end

  def handle_info(:rollup, check) do
    Logger.debug("#{__MODULE__}: Running rollup logic on check #{check.check.id}")
    do_rollup(check.check)
    Process.send_after(self(), :rollup, @interval)
    {:noreply, check}
  end

  def do_rollup(%{id: id} = check) do
    with {:ok, values} <- Value.get_recent_values_by_check_id(id),
         {:ok, alerted?} <- is_alerted?(values),
         {:ok, translated_alerted_state} <- translate_alerted(alerted?)
    do
      # I guess this is where we should fire a thread to determine
      # if we should send a notification
      Logger.debug("#{__MODULE__}: Rollup finished, updating check #{id} to #{translated_alerted_state}")
      :ok = Check.update_check_state(check, translated_alerted_state)
    else
      error ->
        Logger.debug("#{__MODULE__}: Rollup finished, no updates")
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
