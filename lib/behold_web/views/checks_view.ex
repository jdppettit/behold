defmodule BeholdWeb.ChecksView do
  use BeholdWeb, :view

  alias BeholdWeb.Views.Helpers

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

  def render("server_error.json", %{message: message}) do
    %{
      message: message
    }
  end

  def render("invalid_parameters.json", %{message: message}) do
    %{
      message: message
    }
  end

  def reder("invalid_parameters.json", %{message: message}) do
    %{
      message: message
    }
  end
end
