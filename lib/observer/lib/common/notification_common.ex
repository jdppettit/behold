defmodule Observer.Common.Notification do
  require Logger

  alias Behold.Models.Alert
  alias Observer.Common.Common

  def maybe_send_notification(check, last_state_change) do
    with {:ok, _state} <- validate_last_state(last_state_change),
         {:ok, alerts} <- validate_timing(check)
    do
      alerts
      |> Enum.map(fn alert ->
        Logger.debug("#{__MODULE__}: Sending alert type #{alert.type} for #{check.id}")
        case alert.type do
          :email ->
            Observer.Notification.Email.send(check, alert)
            Alert.update_last_sent(alert, Timex.now())
          :sms ->
            Observer.Notification.SMS.send(check, alert)
            Alert.update_last_sent(alert, Timex.now())
          type ->
            Logger.error("#{__MODULE__}: Wanted to fire alert for check #{check.id} but alert type #{inspect(type)} unknown")
        end
      end)
    else
      {:error, :nominal} ->
        Logger.debug("#{__MODULE__}: Did not fire alert for check #{check.id} because state is nominal")
      error ->
        Logger.debug("#{__MODULE__}: Did not fire alert for check #{check.id} because #{inspect(error)}l")
    end
  end

  def validate_last_state(last_state) do
    case last_state do
      :critical ->
        {:ok, :critical}
      :nominal ->
        {:error, :nominal}
    end
  end

  def validate_timing(%{id: id} = _check) do
    {:ok, alerts} = Alert.get_all_valid_alerts(id)
    alerts = alerts
    |> Enum.reduce([], fn alert, acc ->
      next_alert = next_alert_time(alert.last_sent, alert.interval)
      valid? = timing_valid?(next_alert)
      if valid? do
        [alert | acc]
      else
        acc
      end
    end)
    {:ok, alerts}
  end

  def next_alert_time(nil, _interval), do: Timex.now()
  def next_alert_time(last_sent, interval) do
    last_sent
    |> Timex.shift(seconds: Common.convert_from_miliseconds_to_seconds(interval))
  end

  def timing_valid?(next_alert_time) do
    # -1 means the first date is before the second one
    # 0 means they are the same
    # 1 means the first date is after the second one
    case Timex.compare(next_alert_time, Timex.now()) do
      -1 ->
        true
      0 ->
        true
      1 ->
        false
    end
  end
end
