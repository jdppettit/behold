defmodule BeholdWeb.Controller.AlertsControllerTest do
  use BeholdWeb.ConnCase

  alias Behold.Models.{Alert, Check}
  alias BeholdWeb.AlertsController

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

  def create_alert(check_id) do
    {:ok, changeset} = Alert.create_changeset(%{
      target: "foobar@gmail.com",
      interval: nil,
      type: "email",
      check_id: check_id
    })
    {:ok, model} = Alert.insert(changeset)
    model
  end

  describe "alerts controller" do
    test "create successfully creates an alert", %{conn: conn} do
      model = create_check()

      params = %{
        target: "foobar@foo.com",
        type: "email",
        interval: nil,
        check_id: model.id
      }

      resp = post conn, "api/v1/alert", params
      assert resp.status == 200
      response_body = Poison.decode! resp.resp_body
      assert response_body["message"] == "alert created"
      assert not is_nil(response_body["alert"])

      {code, alert_model} = Alert.get_by_id(response_body["alert"]["id"])
      assert code == :ok
      assert is_nil(alert_model) == false
    end

    test "update changes alert with partial input", %{conn: conn} do
      check_model = create_check()
      alert_model = create_alert(check_model.id)

      params = %{
        id: alert_model.id,
        check_id: check_model.id,
        target: "bar@foobar.com",
        type: "sms",
      }

      resp = put conn, "api/v1/alert", params
      assert resp.status == 200
      response_body = Poison.decode! resp.resp_body
      assert response_body["message"] == "alert updated"
      assert is_nil(response_body["alert"]) == false
      assert response_body["alert"]["id"] == alert_model.id
      assert response_body["alert"]["type"] == "sms"
      assert response_body["alert"]["target"] == "bar@foobar.com"
    end

    test "update changes alert with all input", %{conn: conn} do
      check_model = create_check()
      alert_model = create_alert(check_model.id)

      params = %{
        id: alert_model.id,
        check_id: check_model.id,
        target: "bar@foobar.com",
        type: "sms",
        interval: 1000
      }

      resp = put conn, "api/v1/alert", params
      assert resp.status == 200
      response_body = Poison.decode! resp.resp_body
      assert response_body["message"] == "alert updated"
      assert is_nil(response_body["alert"]) == false
      assert response_body["alert"]["id"] == alert_model.id
      assert response_body["alert"]["type"] == "sms"
      assert response_body["alert"]["target"] == "bar@foobar.com"
      assert response_body["alert"]["interval"] == 1000
    end

    test "delete successfully deletes an alert", %{conn: conn} do
      check_model = create_check()
      alert_model = create_alert(check_model.id)

      resp = delete conn, "api/v1/alert", %{id: alert_model.id}
      assert resp.status == 200
      response_body = Poison.decode! resp.resp_body
      assert response_body["message"] == "alert deleted"
    end

    test "get_all returns the expected number of alerts", %{conn: conn} do
      check_model = create_check()
      create_alert(check_model.id)
      create_alert(check_model.id)
      create_alert(check_model.id)
      create_alert(check_model.id)

      resp = get conn, "api/v1/alerts"
      assert resp.status == 200
      response_body = Poison.decode! resp.resp_body
      assert length(response_body["alerts"]) == 4
    end
  end

  describe "misc controller functions" do
    test "validate_type/1 returns true on valid type", _ do
      resp = AlertsController.validate_type("sms")
      assert resp == {:ok, "sms"}
    end

    test "validate_type/1 returns false on invalid type", _ do
      resp = AlertsController.validate_type("reuben_sandwich")
      assert resp == {:error, :bad_type}
    end

    test "extract_params/1 extracts the right params", _ do
      params = %{
        "target" => "bar@foobar.com",
        "type" => "sms",
        "interval" => 1000        
      }

      resp = AlertsController.extract_params(params)
      assert resp == {:ok, %{target: "bar@foobar.com", type: "sms", interval: 1000}}
    end

    test "extract_params/1 excludes garbage", _ do
      params = %{
        "target" => "bar@foobar.com",
        "type" => "sms",
        "interval" => 1000,
        "garbage" => "no thank you"        
      }

      resp = AlertsController.extract_params(params)
      assert resp == {:ok, %{target: "bar@foobar.com", type: "sms", interval: 1000}}
    end

    test "extract_id/1 extracts the id", _ do
      map = %{"id" => 1}

      resp = AlertsController.extract_id(map)
      assert resp == {:ok, 1}
    end

    test "extract_id/1 returns error if no id", _ do
      map = %{"foo" => 1}

      resp = AlertsController.extract_id(map)
      assert resp == {:error, :missing_id}
    end

    test "extract_check_id extracts check_id", _ do
      params = %{"check_id" => 1}

      resp = AlertsController.extract_check_id(params)
      assert resp == {:ok, 1}
    end

    test "filter_nil_keys/1 filters nil keys", _ do
      map = %{
        id: 1,
        foo: nil,
        food: "yes please"
      }

      resp = AlertsController.filter_nil_keys(map)
      assert resp == %{id: 1, food: "yes please"}
    end
  end
end