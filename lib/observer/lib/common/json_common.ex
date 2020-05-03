defmodule Observer.Common.JSON do
  def get(target, value) do
    try do
      {:ok, response} = HTTPoison.get(target)
      parsed_body = Poison.decode!(response.body)
      validate_response(
        parsed_body,
        value |> split_value()
      )
    catch
      _ ->
        false
    end
  end

  def validate_response(parsed_body, value_to_check) do
    try do
      get_in(parsed_body, value_to_check)
      true
    catch
      _ ->
        false
    end
  end

  def split_value(value) do
    value
    |> String.split(".")
  end
end
