defmodule BeholdWeb.Views.Helpers do
  def sanitize(%Behold.Models.Check{} = model) do
    model
    |> Map.drop([
      :__meta__
    ])
  end

  def sanitize(%Behold.Models.Alert{} = model) do
    model
    |> Map.drop([
      :__meta__
    ])
  end
end
