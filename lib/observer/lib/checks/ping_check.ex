defmodule Observer.Check.Ping do
  require Logger

  use GenServer
  use Observer.Common.CheckFramework, name: "Ping"

  alias Observer.Common.{Ping}
  alias Behold.Models.Value

  def do_check(%{target: target, id: id} = _check) do
    case Ping.ping(target) do
      true ->
        {:ok, changeset} = Value.create_changeset(:nominal, id)
        {:ok, _} = Value.insert(changeset)
      _ ->
        {:ok, changeset} = Value.create_changeset(:critical, id)
        {:ok, _} = Value.insert(changeset)
    end
  end
end
