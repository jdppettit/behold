defmodule BeholdWeb.AlertsView do
  use BeholdWeb, :view

  alias BeholdWeb.Views.Helpers

  def render("alert_created.json", %{alert: alert}) do
    %{
      message: "Alert created successfully",
      alert: Helpers.sanitize(alert)
    }
  end
end
