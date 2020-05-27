defmodule BeholdWeb.Views.Helpers do
  def sanitize(%Behold.Models.Check{} = model) do
    model = model
    |> Map.drop([
      :__meta__
    ])

    if is_list(model.alerts) do
      alerts = model
      |> (fn model ->
        model.alerts
      end).()
      |> Enum.map(fn alert ->
        sanitize(alert)
      end)

      Map.replace!(model, :alerts, alerts)
    else
      model
      |> Map.drop([
        :alerts
      ])
    end
  end

  def sanitize(%Behold.Models.Alert{} = model) do
    model
    |> Map.drop([
      :__meta__,
      :check
    ])
  end

  def sanitize(%Behold.Models.Value{} = model) do
    if not is_nil(model.check) and is_map(model.check) do
      updated_model = model
      |> Map.drop([
        :__meta__
      ])

      updated_check_model = model.check
      |> Map.drop([
        :alerts,
        :__meta__
      ])

      Map.replace!(updated_model, :check, updated_check_model)
    else
      model
      |> Map.drop([
        :__meta__,
        :check
      ])
    end
  end
end
