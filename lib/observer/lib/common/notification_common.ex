defmodule Observer.Common.Notification do
  require Logger

  alias Behold.Models.{Alert,Check}
  alias Observer.Common.Common

  @bad_types [:critical, :warning]
  @good_types [:nominal]

  def maybe_send_notification(
    %{id: id} = check,
    last_state_change
  ) do
    with {:ok, alerts} <- Alert.get_all_valid_alerts(id) do
      alerts
      |> Enum.map(fn alert -> maybe_send_notification(check, alert, last_state_change) end)
    else
      e ->
        Logger.error("#{__MODULE__}: Failed to send notification for check #{check.id} because #{inspect(e)}")
    end 
  end

  # This case will only fire the initial bad notification
  # and a recovery notification
  def maybe_send_notification(
    check,
    %{
      interval: interval
    } = alert,
    last_state_change
  ) when is_nil(interval) do
    Logger.debug("#{__MODULE__}: In no interval track")
    determine_notification_to_send(check, alert, last_state_change)
  end

  # This case will fire if there is an interval, this means we should send
  # notifications every time the interval has passed and when recovery happens
  def maybe_send_notification(
    check,
    %{
      interval: interval
    } = alert,
    last_state_change
  ) when not is_nil(interval) do
    Logger.debug("#{__MODULE__}: In interval track")
    determine_notification_to_send(check, alert, last_state_change)
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

  def fire_recovery_notification(check, alert) do
    case alert.type do
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

  def fire_alert_notification(check, alert) do
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

  def determine_notification_to_send(
    %{last_alerted_for: last_alerted_for} = check,
    alert,
    last_state_change
  ) do
    if is_nil(last_alerted_for) do
      Logger.debug("#{__MODULE__}: Notification last alerted state was nil")
      if last_state_change in @bad_types do
        Logger.debug("#{__MODULE__}: Notification last alerted was nil and new state was in bad states, sending bad notification")
        fire_alert_notification(check, alert)
      else
        Logger.debug("#{__MODULE__}: Notification last alerted was nil and new state was in good states, doing nothing")
      end
    else
      if last_alerted_for != last_state_change do
        if last_state_change in @bad_types do
          Logger.debug("#{__MODULE__}: Notification last alerted was #{last_alerted_for} and last_state was in bad types, sending bad notification")
          fire_alert_notification(check, alert)
        else
          if last_alerted_for in @bad_types and last_state_change in @good_types do
            Logger.debug("#{__MODULE__}: Notification last alerted was #{last_alerted_for} and last_state was in good types, sending recovery")
            fire_recovery_notification(check, alert)
          end
        end
      end
    end
  end
end
