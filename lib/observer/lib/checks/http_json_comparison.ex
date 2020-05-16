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
      {true, returned_value} ->
        {:ok, changeset} = Value.create_changeset(:nominal, id, returned_value)
        {:ok, _} = Value.insert(changeset)
      {false, returned_value} ->
        {:ok, changeset} = Value.create_changeset(:critical, id, returned_value)
        {:ok, _} = Value.insert(changeset)
    end
  end
end
