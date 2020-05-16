defmodule Observer.Check.HTTP do
  require Logger

  use GenServer
  use Observer.Common.CheckFramework, name: "HTTP"

  alias Observer.Common.{HTTP}
  alias Behold.Models.Value

  def do_check(%{value: value, target: target, id: id} = _check) do
    case HTTP.get(target, value) do
      {true, returned_value} ->
        {:ok, changeset} = Value.create_changeset(:nominal, id, returned_value)
        {:ok, _} = Value.insert(changeset)
      {false, returned_value} ->
        {:ok, changeset} = Value.create_changeset(:critical, id, returned_value)
        {:ok, _} = Value.insert(changeset)
    end
  end
end
