defmodule Observer.Check.Ping do
  require Logger

  use GenServer
  use Observer.Common.CheckFramework, name: "Ping"

  alias Observer.Common.{Ping}
  alias Behold.Models.Value

  def do_check(%{target: target, id: id} = _check) do
    case Ping.ping(target) do
      {true, returned_value} ->
        {:ok, changeset} = Value.create_changeset(:nominal, id, returned_value)
        {:ok, _} = Value.insert(changeset)
      {false, returned_value} ->
        {:ok, changeset} = Value.create_changeset(:critical, id, returned_value)
        {:ok, _} = Value.insert(changeset)
    end
  end
end
