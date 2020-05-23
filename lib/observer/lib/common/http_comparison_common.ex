defmodule Observer.Common.HTTPComparison do
  require Logger

  def get(path, value) do
    {code, response} = HTTPoison.get(path)
    if code !== :ok do
      {false, "#{inspect(code)}"}
    else
      check_return_value(response, value)
    end
  end

  def check_return_value(response, check_value) do
    try do
      {response.body =~ check_value, format_response_body_for_database(response.body)}
    rescue
      e ->
        Logger.error("#{__MODULE__}: Got error checking return value #{inspect(e)}")
        {false, "error"}
    end 
  end

  def format_response_body_for_database(body) do
    if String.length(body) > 255 do
      body = body |> String.slice(0..251)
      "#{body}..."
    else
      "#{inspect(body)}"
    end
  end
end