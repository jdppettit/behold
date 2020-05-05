defmodule Observer.Check.JSON do
  require Logger

  use GenServer
  use Observer.Common.CheckFramework, name: "JSON"

  alias Observer.Common.{JSON}
  alias Behold.Models.Value

  def do_check(%{value: value, target: target, id: id} = _check) do
    case JSON.get(target, value) do
      true ->
        {:ok, changeset} = Value.create_changeset(:nominal, id)
        {:ok, _} = Value.insert(changeset)
      _ ->
        {:ok, changeset} = Value.create_changeset(:critical, id)
        {:ok, _} = Value.insert(changeset)
    end
  end
end
