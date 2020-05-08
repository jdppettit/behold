defmodule Observer.Common.Notification do
  require Logger

  alias Behold.Models.{Alert,Check}
  alias Observer.Common.Common

  @bad_states [:critical, :warning]
  @good_states [:nominal]

  def maybe_send_notification(check, last_state_change) do
    with {:ok, alerts} <- validate_timing(check) do
      alerts
      |> Enum.map(fn alert ->
        Logger.debug("#{__MODULE__}: Sending alert type #{alert.type} for #{check.id}")
        fire_notification(check, last_state_change, alert)
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

  def fire_notification(check, last_state_change, alert) do
    # If the checks last alerted for is nil
      # If last_state_change is bad, do bad notification
      # If last_state_change is good, probably do nothing
    # Else
      # If checks last alerted is not equal to last state and last state is nominal,
      # alert and then set last alerted to nominal

      # Else
      # Send bad notification
    if is_nil(check.last_alerted_for) do
      if last_state_change in @bad_states do
        IO.inspect("in nil and last state in bad")
        fire_bad_notification(check, alert)
      end
    else
      IO.inspect("in main else")
      if check.last_alerted_for != last_state_change and last_state_change in @good_states do
        IO.inspect("in alerted for not state change and state change in good")
        fire_good_notification(check, alert)
      else
        IO.inspect("in second else")
        if check.last_alerted_for != last_state_change do
          IO.inspect("in check alerted for not last state change")
          fire_bad_notification(check, alert)
        else
          Logger.debug("#{__MODULE__}: Check state and state change matched, no need to notify for #{check.id}")
        end
      end
    end
  end

  def fire_good_notification(check, alert) do
    IO.inspect("firing good notification")
    case check.type do
      :email ->
        Observer.Notification.Email.send(check, alert, :up)
        Alert.update_last_sent(alert, Timex.now())
        Check.update_last_alerted(check, :nominal)
      :sms ->
        Observer.Notification.SMS.send(check, alert, :up)
        Alert.update_last_sent(alert, Timex.now())
        Check.update_last_alerted(check, :nominal)
      type ->
        Logger.error("#{__MODULE__}: Wanted to fire good alert for check #{check.id} but alert type #{inspect(type)} unknown")
    end
  end

  def fire_bad_notification(check, alert) do
    IO.inspect("firing bad notification")
    case alert.type do
      :email ->
        Observer.Notification.Email.send(check, alert, :down)
        Alert.update_last_sent(alert, Timex.now())
        Check.update_last_alerted(check, :critical)
      :sms ->
        Observer.Notification.SMS.send(check, alert, :down)
        Alert.update_last_sent(alert, Timex.now())
        Check.update_last_alerted(check, :critical)
      type ->
        Logger.error("#{__MODULE__}: Wanted to fire bad alert for check #{check.id} but alert type #{inspect(type)} unknown")
    end
  end
end
