defmodule Observer.Common.JSONComparison do
  require Logger
  alias Observer.Common.Common

  def get(target, operation, comparison, value) do
    try do
      {:ok, response} = HTTPoison.get(target)
      parsed_body = Poison.decode!(response.body)
      validate_response(
        parsed_body,
        operation,
        comparison,
        value |> split_value()
      )
    catch
      e ->
        Logger.error("#{__MODULE__}: Error in get JSON Comparison #{inspect(e)}")
        false
    end
  end

  def validate_response(parsed_body, operation, comparison, value_to_check) do
    try do
      case get_in(parsed_body, value_to_check) do
        val when is_nil(val) ->
          false
        val when not is_nil(val) ->
          case is_variable?(comparison) do
            true ->
              handle_comparison_variables(operation, val, comparison)
            false ->
              Common.do_compare(operation, val, comparison)
          end
      end
    catch
      e ->
        Logger.error("#{__MODULE__}: Error in validate response #{inspect(e)}")
        false
    end
  end

  def split_value(value) do
    value
    |> String.split(".")
  end

  def is_variable?(comparison) do
    case comparison do
      "$current_datetime" ->
        true
      "$last_30_minutes" ->
        true
      "$next_30_minutes" ->
        true
      "$datetime" ->
        true
      _ ->
        false
    end
  end

  def handle_comparison_variables(operation, val, "$last_30_minutes") do
    val2 = Timex.now() |> Timex.shift(minutes: -30)
    {:ok, val1} = NaiveDateTime.from_iso8601(val)
    Common.do_compare_date(operation, val1, val2)
  end

  def handle_comparison_variables(operation, val, "$next_30_minutes") do
    val2 = Timex.now() |> Timex.shift(minutes: 30)
    {:ok, val1} = NaiveDateTime.from_iso8601(val)
    Common.do_compare_date(operation, val1, val2)
  end

  def handle_comparison_variables(operation, val, "$current_datetime") do
    val2 = Timex.now()
    {:ok, val1} = NaiveDateTime.from_iso8601(val)
    Common.do_compare_date(operation, val1, val2)
  end
end
