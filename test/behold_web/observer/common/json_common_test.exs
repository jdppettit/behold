defmodule Observer.Common.JSONTest do
  use BeholdWeb.ConnCase
  alias Observer.Common.JSON

  test "validate_response/2 does correct comparison", _ do
    response = JSON.validate_response(%{"thing" => "bar"}, "thing" |> JSON.split_value)
    assert response == true

    response = JSON.validate_response(%{"thing" => %{"fee" => %{"foh" => "fum"}}}, "thing.fee.foh" |> JSON.split_value)
    assert response == true

    response = JSON.validate_response(%{"thing" => %{"fee" => %{"foh" => "fum"}}}, "thing.fee.foh.fum" |> JSON.split_value)
    assert response == false
  end
end
