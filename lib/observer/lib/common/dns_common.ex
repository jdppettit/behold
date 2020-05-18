defmodule Observer.Common.DNS do
  def get(target_server, record_to_check) do
    try do
      case DNS.resolve(record_to_check, :a, {target_server, 53}) do
        {:ok, value} ->
          deconvalue = List.first(value)
          |> (fn {a, b, c, d} = val -> 
            "#{a}.#{b}.#{c}.#{d}"
          end).()
          {true, deconvalue}
        {:error, e} ->
          {false, e}
      end 
    rescue
      e ->
        {false, "could not reach provided server"}
    end
  end
end