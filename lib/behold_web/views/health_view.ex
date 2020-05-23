defmodule BeholdWeb.HealthView do
  use BeholdWeb, :view

  def render("health_data.json", %{health: health}) do
    health
  end
end