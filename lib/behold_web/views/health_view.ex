defmodule BeholdWeb.HealthView do
  use BeholdWeb, :view

  def render("health_data.json", %{health: health}) do
    health
  end

  def render(_, %{message: message}) do
    %{
      message: message
    }
  end
end