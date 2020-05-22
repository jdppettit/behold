defmodule Observer.Common.JSONComparisonTest do
  use BeholdWeb.ConnCase
  alias Observer.Common.JSONComparison

  test "validate_response/4 returns true if value is correct", _ do
    {resp, val} = JSONComparison.validate_response(%{"foo" => "bar"}, :equal_to, "bar", ["foo"])
    assert resp == true
    assert val == "bar"
  end

  test "validate_response/4 returns false if value is incorrect", _ do
    {resp, val} = JSONComparison.validate_response(%{"foo" => "bar"}, :equal_to, "boop", ["foo"])
    assert resp == false
    assert val == "bar"
  end

  test "validate_response/4 returns key not found if checking bad key", _ do
    {resp, val} = JSONComparison.validate_response(%{"bar" => "zap"}, :equal_to, "boop", ["foo"])
    assert resp == false
    assert val == "key not found"
  end

  test "validate_response/4 returns error on error", _ do
    {resp, val} = JSONComparison.validate_response(%{"foo" => "bar"}, :equal_to, "bar", "foo")
    assert resp == false
    assert val == "error"
  end

  test "split_value/1 splits a dot notated string into array", _ do
    resp = JSONComparison.split_value("foo.bar.zap")
    assert resp == ["foo", "bar", "zap"]
  end

  test "split_value/1 returns array with one value if no dots", _ do
    resp = JSONComparison.split_value("icebear")
    assert resp == ["icebear"]
  end

  test "is_variable? returns true if supplied value is a variable", _ do
    resp = JSONComparison.is_variable?("$next_30_minutes")
    assert resp == true
  end

  test "is_variable? returns false if supplied value is not a variable", _ do
    resp = JSONComparison.is_variable?("$icebear_has_ninja_stars")
    assert resp == false
  end
end