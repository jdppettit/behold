defmodule Observer.Common.Common do
  alias Observer.Cron.Rollup

  def convert_string_to_int(string) when is_nil(string), do: {:error, string}
  def convert_string_to_int(string) when is_integer(string), do: {:ok, string}
  def convert_string_to_int(string) do
    {int, _} = Integer.parse(string)
    {:ok, int}
  end

  def compare(op, val1, val2) do
    {_, val2_converted} = convert_string_to_int(val2)
    do_compare(op, val1, val2_converted)
  end

  def do_compare(:greater_than, val1, val2) do
    val1 > val2
  end

  def do_compare(:less_than, val1, val2) do
    val1 < val2
  end

  def do_compare(:greater_than_or_equal_to, val1, val2) do
    val1 >= val2
  end

  def do_compare(:less_than_or_equal_to, val1, val2) do
    val1 <= val2
  end

  def do_compare(:equal_to, val1, val2) do
    val1 == val2
  end

  def do_compare(:not_equal_to, val1, val2) do
    val1 != val2
  end

  def do_compare_date(:greater_than, val1, val2) do
    c = Timex.compare(val1, val2)
    case c do
      -1 ->
        false
      0 ->
        false
      1 ->
        true
    end
  end

  def do_compare_date(:less_than, val1, val2) do
    c = Timex.compare(val1, val2)
    case c do
      -1 ->
        true
      0 ->
        false
      1 ->
        false
    end
  end

  def do_compare_date(:greater_than_or_equal_to, val1, val2) do
    c = Timex.compare(val1, val2)
    case c do
      -1 ->
        false
      0 ->
        true
      1 ->
        true
    end
  end

  def do_compare_date(:less_than_or_equal_to, val1, val2) do
    c = Timex.compare(val1, val2)
    case c do
      -1 ->
        true
      0 ->
        true
      1 ->
        false
    end
  end

  def do_compare_date(:equal_to, val1, val2) do
    c = Timex.compare(val1, val2)
    case c do
      -1 ->
        false
      0 ->
        true
      1 ->
        false
    end
  end

  def do_compare_date(:not_equal_to, val1, val2) do
    c = Timex.compare(val1, val2)
    case c do
      -1 ->
        true
      0 ->
        false
      1 ->
        true
    end
  end

  def convert_float_to_integer(float) when is_integer(float), do: {:ok, float}
  def convert_float_to_integer(float) do
    {:ok, round(float)}
  end

  def convert_from_miliseconds_to_seconds(miliseconds) do
    seconds = miliseconds / 1000
    {:ok, int} = convert_float_to_integer(seconds)
    int
  end

  def convert_to_string(val) when is_integer(val) do
    Integer.to_string(val)
  end

  def convert_to_string(val) when is_float(val) do
    Float.to_string(val)
  end

  def convert_to_string(val) when is_atom(val) do
    Atom.to_string(val)
  end

  def convert_to_string(val), do: val
end
