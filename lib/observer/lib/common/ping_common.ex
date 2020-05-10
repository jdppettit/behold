defmodule Observer.Common.Ping do
  def ping(host) do
    case System.cmd("ping", [host, "-c 1"]) do
      {result, 0} ->
        check_result(result)
      {_, _} ->
        false
    end
  end

  def check_result(result) do
    result = result
    |> String.split("\n")
    |> Enum.at(4)

    if is_nil(result) do
      false
    else
      Regex.scan(~r/[0-9]/, result, capture: :all)
      |> List.flatten
      |> (fn list ->
        first = Enum.at(list, 0)
        second = Enum.at(list, 1)
        first == second
      end).()
    end
  end
end
