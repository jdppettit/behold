defmodule Observer.Common.HTTPComparisonTest do
  use BeholdWeb.ConnCase
  alias Observer.Common.HTTPComparison

  test "check_return_value/2 returns true if value is present", _ do
    {resp, _val} = HTTPComparison.check_return_value(%{body: "<div>foobar</div>"}, "foobar")
    assert resp == true
  end

  test "check_return_value/2 returns false if value is not present", _ do
    {resp, _val} = HTTPComparison.check_return_value(%{body: "<div>foobar</div>"}, "<a>")
    assert resp == false
  end

  test "check_return_value/2 returns error if error", _ do
    {resp, val} = HTTPComparison.check_return_value("foobar", "foobar")
    assert resp == false
    assert val == "error"
  end
end