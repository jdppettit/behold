defmodule Observer.Common.PingTest do
  use BeholdWeb.ConnCase
  alias Observer.Common.Ping

  test "check_result/1 correctly parses out data for successful ping", _ do
    string = """
    PING 10.0.0.1 (10.0.0.1): 56 data bytes
    64 bytes from 10.0.0.1: icmp_seq=0 ttl=64 time=9.567 ms

    --- 10.0.0.1 ping statistics ---
    1 packets transmitted, 1 packets received, 0.0% packet loss
    round-trip min/avg/max/stddev = 9.567/9.567/9.567/0.000 ms
    """

    response = Ping.check_result(string)
    assert response == true

    string = """
    PING 10.0.0.1 (10.0.0.1): 56 data bytes
    64 bytes from 10.0.0.1: icmp_seq=0 ttl=64 time=9.567 ms

    --- 10.0.0.1 ping statistics ---
    1 packets transmitted, 0 packets received, 0.0% packet loss
    round-trip min/avg/max/stddev = 9.567/9.567/9.567/0.000 ms
    """

    response = Ping.check_result(string)
    assert response == false

    response = Ping.check_result("foo")
    assert response == false
  end
end
