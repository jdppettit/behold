defmodule Observer.Common.CommonTest do
  use BeholdWeb.ConnCase

  alias Observer.Common.Common

  test "convert_float_to_integer/1 returns ok when int provided", _ do
    response = Common.convert_float_to_integer(1)
    assert response == {:ok, 1}
  end

  test "convert_float_to_integer/1 returns ok when float provided", _ do
    response = Common.convert_float_to_integer(1.2)
    assert response == {:ok, 1}
  end

  test "convert_from_miliseconds_to_seconds/1 does conversion correctly", _ do
    response = Common.convert_from_miliseconds_to_seconds(1000)
    assert response == 1

    response = Common.convert_from_miliseconds_to_seconds(10000)
    assert response == 10

    response = Common.convert_from_miliseconds_to_seconds(100000)
    assert response == 100
  end

  test "convert_string_to_int/1 returns error when provided nil", _ do
    response = Common.convert_string_to_int(nil)
    assert response == {:error, nil}
  end

  test "convert_string_to_int/1 returns ok when provided int", _ do
    response = Common.convert_string_to_int(1)
    assert response == {:ok, 1}
  end

  test "convert_string_to_int/1 returns ok when provided string", _ do
    response = Common.convert_string_to_int("1")
    assert response == {:ok, 1}
  end

  test "compare/3 converts to ints and passes through correctly", _ do
    response = Common.compare(:greater_than, "2", "1")
    assert response == true

    response = Common.compare(:less_than, 2, "1")
    assert response == false
  end

  test "do_compare/3 greater than does greater than", _ do
    response = Common.do_compare(:greater_than, 2, 1)
    assert response == true

    response = Common.do_compare(:greater_than, 1, 2)
    assert response == false
  end

  test "do_compare/3 less than does less than", _ do
    response = Common.do_compare(:less_than, 2, 1)
    assert response == false

    response = Common.do_compare(:less_than, 1, 2)
    assert response == true
  end

  test "do_compare/3 greater than or equal to does >=", _ do
    response = Common.do_compare(:greater_than_or_equal_to, 2, 1)
    assert response == true

    response = Common.do_compare(:greater_than_or_equal_to, 2, 2)
    assert response == true

    response = Common.do_compare(:greater_than_or_equal_to, 1, 2)
    assert response == false
  end
end
