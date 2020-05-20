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
      type: "dns"
    })
    {:ok, model} = Check.insert(changeset)
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
  end
end