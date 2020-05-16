defmodule Observer.Check.JSON do
  require Logger

  use GenServer
  use Observer.Common.CheckFramework, name: "JSON"

  alias Observer.Common.{JSON}
  alias Behold.Models.Value

  def do_check(%{value: value, target: target, id: id} = _check) do
    case JSON.get(target, value) do
      {true, returned_value} ->
        {:ok, changeset} = Value.create_changeset(:nominal, id, returned_value)
        {:ok, _} = Value.insert(changeset)
      {false, returned_value} ->
        {:ok, changeset} = Value.create_changeset(:critical, id, returned_value)
        {:ok, _} = Value.insert(changeset)
    end
  end
end
