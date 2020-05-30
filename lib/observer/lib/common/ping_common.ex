defmodule Observer.Common.Ping do
  alias Observer.Common.Common
  require Logger

  def ping(host) do
    try do
      formatted_host = host |> format_host()
      case Ping.ping(formatted_host) do
        {:ok, details} ->
          {true, details}
        {:error, :timeout} ->
          {false, "timeout"}
        {:error, :icmp_error} ->
          {false, "icmp_error"}
        {:error, :permission_error} ->
          {false, "permission error"}
        e ->
          Logger.error("#{__MODULE__}: Got error #{inspect(e)} doing ping")
          {false, "unexpected error"}
      end 
    rescue
      e ->
        Logger.error("#{__MODULE__}: Unexpected error in ping check: #{inspect(e)}")
        {false, "unexpected error"}
    end
  end

  def format_host(string) do
    string
    |> String.split(".")
    |> Enum.map(fn item -> 
      {:ok, int} = Common.convert_string_to_int(item)
      int
    end)
    |> (fn list -> 
        list 
        |> List.to_tuple
    end).()
  end
end
