defmodule Observer.Common.DNSTest do
  use BeholdWeb.ConnCase
  alias Observer.Common.DNS

  test "get/1 returns true on successful check", _ do
    {resp, _val} = DNS.get("8.8.8.8", "google.com")
    assert resp == true
  end

  test "get/1 returs false on not successful check", _ do
    {resp, _val} = DNS.get("8.8.8.8", "fooba.sygll.com")
    assert resp == false
  end

  #test "get/1 returns error if supplied invalid resolver", _ do
  #  {resp, val} = DNS.get("0.0.0.0", "foo.bar.com")
  #  assert resp == false
  #  assert val == "could not reach provided server"
  #end
end