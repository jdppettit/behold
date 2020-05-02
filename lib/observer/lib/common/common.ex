defmodule Observer.Common.Common do
  alias Observer.Cron.Rollup

  def convert_string_to_int(string) when is_nil(string), do: {:error, nil}
  def convert_string_to_int(string) when is_integer(string), do: {:ok, string}
  def convert_string_to_int(string) do
    {int, _} = Integer.parse(string)
    {:ok, int}
  end

  def start_rollup(check) do
    if is_nil(Process.whereis(String.to_atom("#{check.id}-rollup"))) do
      Rollup.start_link(check)
    end
  end
end
