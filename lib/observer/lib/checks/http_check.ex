defmodule Observer.Check.HTTP do
  require Logger
  
  use GenServer
  use Observer.Common.CheckFramework, name: "HTTP"

  alias Observer.Common.{HTTP}
  alias Behold.Models.Value

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
