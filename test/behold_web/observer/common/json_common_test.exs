defmodule Observer.Common.JSONTest do
  use BeholdWeb.ConnCase
  alias Observer.Common.JSON

  test "validate_response/2 does correct comparison", _ do
    response = JSON.validate_response(%{"thing" => "bar"}, "thing" |> JSON.split_value)
    assert response == {true, "bar"}

    response = JSON.validate_response(%{"thing" => %{"fee" => %{"foh" => "fum"}}}, "thing.fee.foh" |> JSON.split_value)
    assert response == {true, "fum"}

    response = JSON.validate_response(%{"thing" => %{"fee" => %{"foh" => "fum"}}}, "thing.fee.foh.fum" |> JSON.split_value)
    assert response == {false, "invalid json"}
  end

  test "split_value/1 returns a string split by periods", _ do
    response = JSON.split_value("thing")
    assert response == ["thing"]

    response = JSON.split_value("thing.foo.bar")
    assert response == ["thing", "foo", "bar"]
  end
end
