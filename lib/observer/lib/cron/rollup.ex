defmodule Observer.Cron.Rollup do
  use GenServer

  require Logger

  alias Behold.Models.Value
  alias Behold.Models.Check
  alias Behold.Models.Log
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

  def handle_info(:rollup, %{check: %{interval: interval, id: id}} = check) do
    Logger.debug("#{__MODULE__}: Running rollup logic on check #{id}")
    check = do_rollup(check.check)
    Process.send_after(self(), :rollup, interval)
    {:noreply, %{check: Map.from_struct(check)}}
  end

  def do_rollup(%{id: id} = check) do
    IO.inspect(id, label: "id")
    with {:ok, values} <- Value.get_recent_values_by_check_id(id),
         {:ok, alerted?} <- is_alerted?(values),
         {:ok, translated_alerted_state} <- translate_alerted(alerted?),
         {:ok, check} <- Check.update_check_state(check, translated_alerted_state)
    do
      log_event(check, alerted?, translated_alerted_state)
      Logger.debug("#{__MODULE__}: Rollup finished, updating check #{id} to #{translated_alerted_state}")
      Notification.maybe_send_notification(check, translated_alerted_state)
      check
    else
      error ->
        {:ok, changeset} = Log.create_changeset(%{
          type: :rollup_result,
          result: "Ran rollup, resulted in error: #{inspect(error)}",
          target_id: id,
          target_type: :check
        })
        {:ok, _model} = Log.insert(changeset)

        Logger.error("#{__MODULE__}: Rollup error: #{inspect(error)}")
    end
  end

  def is_alerted?(values, threshold \\ @default_threshold) do
    Logger.debug("#{__MODULE__}: Got these values: #{inspect(values)}")
    non_ok_count = values
    |> Enum.filter(fn v ->
      v.value == :critical
    end)
    Logger.debug("#{__MODULE__}: Got these non_ok_values: #{inspect(non_ok_count)}")
    {:ok, length(non_ok_count) == threshold}
  end

  def translate_alerted(true), do: {:ok, :critical}
  def translate_alerted(false), do: {:ok, :nominal}

  def log_event(%{id: id} = check, alerted?, translated_alerted_state) do
    {_, changeset} = Log.create_changeset(%{
      type: :rollup_result,
      result: "Ran rollup, alerted was #{inspect(alerted?)}, updating check state to #{inspect(translated_alerted_state)}",
      target_id: id,
      target_type: :check
    })
    Log.insert(changeset)
  end 
end
