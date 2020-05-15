defmodule BeholdWeb.ValuesView do
  use BeholdWeb, :view

  alias BeholdWeb.Views.Helpers

  def render("values.json", %{values: values}) do
    %{
      values: Enum.map(values, &Helpers.sanitize(&1))
    }
  end

  def render(_, %{message: message}) do
    %{
      message: message
    }
  end
end