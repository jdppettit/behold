defmodule Observer.Common.Notification do
  require Logger

  alias Behold.Models.Alert

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
          :sms ->
            Observer.Notification.SMS.send(check, alert)
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
      [alert | acc]
    end)
    {:ok, alerts}
  end
end
