defmodule BeholdWeb.Controller.ChecksControllerTest do
  use BeholdWeb.ConnCase

  alias Behold.Models.Check
  alias BeholdWeb.ChecksController

  @check_params %{
    value: "<HEAD>",
    type: "http_comparison",
    target: "http://google.com",
    name: "Local DNS Check",
    interval: 5000,
    unique_id: "foo"
  }

  @check_params_bad_type %{
    value: "<HEAD>",
    type: "spaghetti_carbonara",
    target: "http://google.com",
    name: "Local DNS Check",
    interval: 5000,
    unique_id: "foo"
  }

  def create_check() do
    {:ok, changeset} = Check.create_changeset(%{
      value: "foo.bar.com",
      interval: 5000,
      name: "test",
      target: "foo.com",
      type: "dns",
      unique_id: "foo"
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

    test "get all checks returns right number of checks", %{conn: conn} do
      create_check()

      resp = get conn, "api/v1/checks"
      assert resp.status == 200
      response_body = Poison.decode! resp.resp_body
      assert is_nil(response_body["checks"]) == false
      assert length(response_body["checks"]) == 1
    end

    test "delete actually deletes the check", %{conn: conn} do
      model = create_check()

      resp = delete conn, "api/v1/check", %{id: model.id}
      assert resp.status == 200
      response_body = Poison.decode! resp.resp_body
      assert response_body["message"] == "check deleted successfully"
      {code, check_model} = Check.get_by_id(model.id)
      assert code == :error
      assert check_model == :not_found
    end
  end

  describe "misc functions in checks controller" do
    test "validate_type/1 returns ok when provided good type", _ do
      resp = ChecksController.validate_type(:http)
      assert resp == {:ok, :http}
    end

    test "validate_type/2 returns error when provided bad type", _ do
      resp = ChecksController.validate_type(:mcchicken_sandwich)
      assert resp == {:error, :bad_type}
    end

    test "extract_params/1 picks keys from map and returns nil filtered map", _ do
      map = %{
        "target" => "google.com"
      }

      resp = ChecksController.extract_params(map)
      assert resp == {:ok, %{target: "google.com"}}
    end

    test "extract_params/1 excludes null keys", _ do
      map = %{
        "target" => "google.com",
        "operation" => nil
      }

      resp = ChecksController.extract_params(map)
      assert resp == {:ok, %{target: "google.com"}}
    end

    test "extract_params/1 excludes non valid keys", _ do
      map = %{
        "target" => "google.com",
        "whopper" => "is good"
      }

      resp = ChecksController.extract_params(map)
      assert resp == {:ok, %{target: "google.com"}}
    end

    test "extract_id/1 extracts the id", _ do
      map = %{"id" => 1}

      resp = ChecksController.extract_id(map)
      assert resp == {:ok, 1}
    end

    test "extract_id/1 returns error if no id", _ do
      map = %{"foo" => 1}

      resp = ChecksController.extract_id(map)
      assert resp == {:error, :missing_id}
    end

    test "filter_nil_keys/1 filters nil keys", _ do
      map = %{
        id: 1,
        foo: nil,
        food: "yes please"
      }

      resp = ChecksController.filter_nil_keys(map)
      assert resp == %{id: 1, food: "yes please"}
    end
  end
end