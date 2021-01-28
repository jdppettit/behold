defmodule Behold.Common.Statistics do

  @emit_datadog Application.get_env(:behold, :emit_datadog, false)

  def incr(metric_name, opts \\ []) do
    :ok
  end
end