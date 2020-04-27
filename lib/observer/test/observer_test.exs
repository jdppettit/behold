defmodule ObserverTest do
  use ExUnit.Case
  doctest Observer

  test "greets the world" do
    assert Observer.hello() == :world
  end
end
