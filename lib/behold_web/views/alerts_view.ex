defmodule BeholdWeb.AlertsView do
  use BeholdWeb, :view

  alias BeholdWeb.Views.Helpers

  def render("alert_created.json", %{alert: alert}) do
    %{
      message: "Alert created successfully",
      alert: Helpers.sanitize(alert)
    }
  end

  def render("alert_updated.json", %{alert: alert}) do
    %{
      message: "Alert updated",
      alert: Helpers.sanitize(alert)
    }
  end

  def render("alerts.json", %{alerts: alerts}) do
    %{
      message: "Success",
      alerts: Enum.map(alerts, fn alert -> Helpers.sanitize(alert) end)
    }
  end

  def render(_, %{message: message}) do
    %{
      message: message
    }
  end
end
