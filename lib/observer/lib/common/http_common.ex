defmodule Observer.Common.HTTP do
  alias Observer.Common.Common

  def get(path, value) do
    {:ok, response} = HTTPoison.get(path)
    check_return_value(response.status_code, value)
  end

  def check_return_value(return_value, check_value) do
    with {:ok, check_value} <- Common.convert_string_to_int(check_value) do
      return_value == check_value
    else
      _ ->
        false
    end
  end
end
