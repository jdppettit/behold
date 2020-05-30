defmodule Observer.Common.DNS do
  def get(target_server, record_to_check) do
    try do
      case DNS.resolve(record_to_check, :a, {target_server, 53}) do
        {:ok, value} ->
          {true, deconstruct_value(value)}
        {:error, e} ->
          {false, e}
        e ->
          IO.inspect(e)
          raise e
      end 
    rescue
      e ->
        IO.inspect(e);
        {false, "could not reach provided server"}
    end
  end

  def deconstruct_value(value) do
    if length(value) > 1 do
      List.last(value)
      |> (fn {a, b, c, d} = _val -> 
        "#{a}.#{b}.#{c}.#{d}"
      end).()
    else
      List.first(value)
      |> (fn {a, b, c, d} = _val -> 
        "#{a}.#{b}.#{c}.#{d}"
      end).() 
    end
  end
end