defmodule Observer.Check.HTTP do
  use GenServer

  require Logger

  alias Observer.Common.{HTTP}
  alias Behold.Models.Value

  def start_link(check) do
    Logger.debug("#{__MODULE__}: Starting HTTP check for check #{check.id}")
    GenServer.start_link(__MODULE__, check, name: String.to_atom("#{check.id}-#{Atom.to_string(check.type)}"))
  end

  def init(%{interval: interval} = check) do
    Process.send_after(self(), :fire_check, interval)
    {:ok, %{check: check}}
  end

  def handle_info(:fire_check, %{check: %{interval: interval}} = check) do
    do_check(check.check)
    Process.send_after(self(), :fire_check, interval)
    {:noreply, %{check: check.check}}
  end

  def do_check(%{value: value, target: target, id: id} = check) do
    case HTTP.get(target, value) do
      true ->
        {:ok, changeset} = Value.create_changeset(:nominal, id)
        {:ok, _} = Value.insert(changeset)
      _ ->
        {:ok, changeset} = Value.create_changeset(:critical, id)
        {:ok, _} = Value.insert(changeset)
    end
  end
end
