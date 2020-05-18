defmodule Observer.Common.HTTPComparison do
  def get(path, value) do
    {code, response} = HTTPoison.get(path)
    if code !== :ok do
      {false, "#{inspect(code)}"}
    else
      check_return_value(response, value)
    end
  end

  def check_return_value(response, check_value) do
    {response.body =~ check_value, inspect(response.body)}
  end
end