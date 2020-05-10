defmodule BeholdWeb.ChecksView do
  use BeholdWeb, :view

  alias BeholdWeb.Views.Helpers

  def render("checks.json", %{checks: checks}) do
    %{
      checks: Enum.map(checks, &Helpers.sanitize(&1))
    }
  end

  def render("check.json", %{check: check}) do
    %{
      check: Helpers.sanitize(check),
    }
  end

  def render("check_created.json", %{check: check}) do
    %{
      check: Helpers.sanitize(check),
      message: "check created"
    }
  end

  def render("check_deleted.json", _) do
    %{
      message: "check deleted successfully"
    }
  end

  def render("check_updated.json", %{check: check}) do
    %{
      check: Helpers.sanitize(check),
      message: "check updated"
    }
  end

  def render(_, %{message: message}) do
    %{
      message: message
    }
  end
end
