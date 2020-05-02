defmodule Observer.Common.Common do
  alias Observer.Cron.Rollup

  def convert_string_to_int(string) when is_nil(string), do: {:error, nil}
  def convert_string_to_int(string) when is_integer(string), do: {:ok, string}
  def convert_string_to_int(string) do
    {int, _} = Integer.parse(string)
    {:ok, int}
  end
end
