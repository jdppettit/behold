defmodule Observer.Common.PingTest do
  use BeholdWeb.ConnCase
  alias Observer.Common.Ping

  test "format_host/1 correctly formats string host", _ do
    host = "1.1.1.1"
    resp = Observer.Common.Ping.format_host(host)
    assert resp == {1,1,1,1}
  end
end
