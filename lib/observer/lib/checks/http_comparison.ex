defmodule Observer.Check.HTTPComparison do
  require Logger

  use GenServer
  use Observer.Common.CheckFramework, name: "HTTPComparison"

  alias Observer.Common.{HTTPComparison}
  alias Behold.Models.Value

  def do_check(%{value: value, target: target, id: id} = _check) do
    case HTTPComparison.get(target, value) do
      true ->
        {:ok, changeset} = Value.create_changeset(:nominal, id)
        {:ok, _} = Value.insert(changeset)
      _ ->
        {:ok, changeset} = Value.create_changeset(:critical, id)
        {:ok, _} = Value.insert(changeset)
    end
  end
end
