defmodule BeholdWeb.Controller.ChecksControllerTest do
  use BeholdWeb.ConnCase

  alias Behold.Models.Check

  @check_params %{
    value: "<HEAD>",
    type: "http_comparison",
    target: "http://google.com",
    name: "Local DNS Check",
    interval: 5000
  }

  @check_params_bad_type %{
    value: "<HEAD>",
    type: "spaghetti_carbonara",
    target: "http://google.com",
    name: "Local DNS Check",
    interval: 5000
  }

  def create_check() do
    {:ok, changeset} = Check.create_changeset(%{
      value: "foo.bar.com",
      interval: 5000,
      name: "test",
      target: "foo.com",
      type: "dns"
    })
    {:ok, model} = Check.insert(changeset)
    model
  end

  describe "checks controller" do
    test "create successfully creates check", %{conn: conn} do
      resp = post conn, "api/v1/check", @check_params
      assert resp.status == 200
      response_body = Poison.decode! resp.resp_body
      assert response_body["message"] == "check created"
      assert not is_nil(response_body["check"])

      {code, check_model} = Check.get_by_id(response_body["check"]["id"])
      assert code == :ok
      assert is_nil(check_model) == false
    end

    test "create rejects bad types on create check", %{conn: conn} do
      resp = post conn, "api/v1/check", @check_params_bad_type
      assert resp.status == 400
      response_body = Poison.decode! resp.resp_body
      assert response_body["message"] == "Unexpected type provided"
    end

    test "update changes check with partial input", %{conn: conn} do
      model = create_check()

      params = %{
        value: "<HEAD>",
        type: "http_comparison",
        target: "http://google.com",
        interval: 5000,
        id: model.id
      }

      resp = put conn, "api/v1/check", params
      assert resp.status == 200
      response_body = Poison.decode! resp.resp_body
      assert response_body["message"] == "check updated"
      assert is_nil(response_body["check"]) == false
      assert response_body["check"]["id"] == model.id
      assert response_body["check"]["type"] == "http_comparison"
      assert response_body["check"]["name"] == model.name
    end

    test "update changes check with all input", %{conn: conn} do
      model = create_check()

      params = %{
        value: "hi",
        type: "ping",
        target: "http://google.com",
        interval: 5000,
        id: model.id,
        name: "foobar"
      }

      resp = put conn, "api/v1/check", params
      assert resp.status == 200
      response_body = Poison.decode! resp.resp_body
      assert response_body["message"] == "check updated"
      assert is_nil(response_body["check"]) == false
      assert response_body["check"]["id"] == model.id
      assert response_body["check"]["type"] == "ping"
      assert response_body["check"]["name"] == "foobar"
      assert response_body["check"]["value"] == "hi"
    end

    test "get returns expected check", %{conn: conn} do
      model = create_check()

      resp = get conn, "api/v1/check/#{model.id}"
      assert resp.status == 200
      response_body = Poison.decode! resp.resp_body
      assert is_nil(response_body["check"]) == false
      assert response_body["check"]["id"] == model.id
      assert response_body["check"]["type"] == Atom.to_string(model.type)
      assert response_body["check"]["name"] == model.name
      assert response_body["check"]["value"] == model.value
    end

    test "get returns 404 for check that doesnt exist", %{conn: conn} do

      resp = get conn, "api/v1/check/049802948314"
      assert resp.status == 404
    end
  end
end