defmodule Observer.Check.JSONComparison do
  require Logger

  use GenServer
  use Observer.Common.CheckFramework, name: "JSONComparison"

  alias Observer.Common.{JSONComparison}
  alias Behold.Models.Value

  def do_check(%{
    value: value,
    target: target,
    id: id,
    comparison: comparison,
    operation: operation
  } = _check) do
    case JSONComparison.get(target, operation, comparison, value) do
      true ->
        {:ok, changeset} = Value.create_changeset(:nominal, id)
        {:ok, _} = Value.insert(changeset)
      _ ->
        {:ok, changeset} = Value.create_changeset(:critical, id)
        {:ok, _} = Value.insert(changeset)
    end
  end
end
