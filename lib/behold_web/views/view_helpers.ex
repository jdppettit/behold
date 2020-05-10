defmodule BeholdWeb.Views.Helpers do
  def sanitize(%Behold.Models.Check{} = model) do
    model = model
    |> Map.drop([
      :__meta__
    ])

    alerts = model
    |> (fn model ->
      model.alerts
    end).()
    |> Enum.map(fn alert ->
      sanitize(alert)
    end)

    Map.replace!(model, :alerts, alerts)
  end

  def sanitize(%Behold.Models.Alert{} = model) do
    model
    |> Map.drop([
      :__meta__,
      :check
    ])
  end
end
