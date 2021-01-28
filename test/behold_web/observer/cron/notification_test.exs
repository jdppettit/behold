defmodule Observer.Cron.NotificationTest do
  use ExUnit.Case
  import Mox
  alias Behold.Models.{Check,Alert,Notification}
  alias Observer.Cron.Notification
  alias Observer.Notification.Email

  setup :verify_on_exit!

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Behold.Repo)
  end

  defp setup_nil_to_down() do
    params = %{
      type: :ping,
      value: "nil",
      interval: 1000,
      target: "10.0.0.1",
      unique_id: "unique"
    }
    {:ok, changeset} = Check.create_changeset(params)
    {:ok, check} = Check.insert(changeset)

    {:ok, check} = Check.update_check_state(Map.from_struct(check), :critical)

    {:ok, changeset} = Alert.create_changeset(:email, "foo@bar.com", 1_000, check.id, nil)
    {:ok, _alert} = Alert.insert(changeset)

    {:ok, check}
  end
  
  defp setup_nil_to_up() do
    params = %{
      type: :ping,
      value: "nil",
      interval: 1000,
      target: "10.0.0.1",
      unique_id: "unique"
    }
    {:ok, changeset} = Check.create_changeset(params)
    {:ok, check} = Check.insert(changeset)

    {:ok, check} = Check.update_check_state(Map.from_struct(check), :nominal)

    {:ok, changeset} = Alert.create_changeset(:email, "foo@bar.com", 1_000, check.id, nil)
    {:ok, _alert} = Alert.insert(changeset)

    {:ok, check}
  end

  defp setup_down_to_up() do
    params = %{
      type: :ping,
      value: "nil",
      interval: 1000,
      target: "10.0.0.1",
      unique_id: "unique",
      last_alerted_for: :critical
      
    }
    {:ok, changeset} = Check.create_changeset(params)
    {:ok, check} = Check.insert(changeset)

    {:ok, check} = Check.update_check_state(Map.from_struct(check), :nominal)

    {:ok, changeset} = Alert.create_changeset(:email, "foo@bar.com", 1_000, check.id, nil)
    {:ok, _alert} = Alert.insert(changeset)

    {:ok, check}
  end

  defp setup_down_to_down() do
    params = %{
      type: :ping,
      value: "nil",
      interval: 1000,
      target: "10.0.0.1",
      unique_id: "unique",
      last_alerted_for: :critical
      
    }
    {:ok, changeset} = Check.create_changeset(params)
    {:ok, check} = Check.insert(changeset)

    {:ok, check} = Check.update_check_state(Map.from_struct(check), :critical)

    {:ok, changeset} = Alert.create_changeset(:email, "foo@bar.com", 1_000, check.id, nil)
    {:ok, _alert} = Alert.insert(changeset)

    {:ok, check}
  end

  defp setup_up_to_down() do
    params = %{
      type: :ping,
      value: "nil",
      interval: 1000,
      target: "10.0.0.1",
      unique_id: "unique",
      last_alerted_for: :nominal
      
    }
    {:ok, changeset} = Check.create_changeset(params)
    {:ok, check} = Check.insert(changeset)

    {:ok, check} = Check.update_check_state(Map.from_struct(check), :critical)

    {:ok, changeset} = Alert.create_changeset(:email, "foo@bar.com", 1_000, check.id, nil)
    {:ok, _alert} = Alert.insert(changeset)

    {:ok, check}
  end

  defp setup_up_to_up() do
    params = %{
      type: :ping,
      value: "nil",
      interval: 1000,
      target: "10.0.0.1",
      unique_id: "unique",
      last_alerted_for: :nominal
      
    }
    {:ok, changeset} = Check.create_changeset(params)
    {:ok, check} = Check.insert(changeset)

    {:ok, check} = Check.update_check_state(Map.from_struct(check), :nominal)

    {:ok, changeset} = Alert.create_changeset(:email, "foo@bar.com", 1_000, check.id, nil)
    {:ok, _alert} = Alert.insert(changeset)

    {:ok, check}
  end

  test "last_state of nil and current_state of down sends one down notification" do
    {:ok, check} = setup_nil_to_down()

    EmailNotificationMock
    |> expect(:send, fn _, _, val -> 
      assert val == :down
      {:ok, nil}
    end)

    Notification.do_notification(Map.from_struct(check))

    # Refresh check and confirm running again wont notify again
    {:ok, check} = Check.get_by_id(check.id)
    Notification.do_notification(Map.from_struct(check))
  end

  test "last_state of nil and current_state of up sends no notification" do
    {:ok, check} = setup_nil_to_up()

    Notification.do_notification(Map.from_struct(check))

    # Refresh check and confirm running again wont notify again
    {:ok, check} = Check.get_by_id(check.id)
    Notification.do_notification(Map.from_struct(check))
  end

  test "last_state of critical and current_state of nominal sends one recovery notification" do
    {:ok, check} = setup_down_to_up()

    EmailNotificationMock
    |> expect(:send, fn _, _, val -> 
      assert val == :up
      {:ok, nil}
    end)

    Notification.do_notification(Map.from_struct(check))

    # Refresh check and confirm running again wont notify again
    {:ok, check} = Check.get_by_id(check.id)
    Notification.do_notification(Map.from_struct(check))
  end

  test "last_state of critical and current_state of critical sends no notification" do
    {:ok, check} = setup_down_to_down()

    Notification.do_notification(Map.from_struct(check))

    # Refresh check and confirm running again wont notify again
    {:ok, check} = Check.get_by_id(check.id)
    Notification.do_notification(Map.from_struct(check))
  end

  test "last_state of nominal and current_state of critical sends one down notification" do
    {:ok, check} = setup_up_to_down()

    EmailNotificationMock
    |> expect(:send, fn _, _, val -> 
      assert val == :down
      {:ok, nil}
    end)

    Notification.do_notification(Map.from_struct(check))

    # Refresh check and confirm running again wont notify again
    {:ok, check} = Check.get_by_id(check.id)
    Notification.do_notification(Map.from_struct(check))
  end

  test "last_state of nominal and current_state of nominal sends no notification" do
    {:ok, check} = setup_up_to_up()

    Notification.do_notification(Map.from_struct(check))

    # Refresh check and confirm running again wont notify again
    {:ok, check} = Check.get_by_id(check.id)
    Notification.do_notification(Map.from_struct(check))
  end

  test "only one notification is sent regardless of how many notification loops execute" do
    {:ok, check} = setup_up_to_down()

    EmailNotificationMock
    |> expect(:send, fn _, _, val -> 
      assert val == :down
      {:ok, nil}
    end)

    Notification.do_notification(Map.from_struct(check))

    # Refresh check and confirm running again wont notify again
    {:ok, check} = Check.get_by_id(check.id)
    Notification.do_notification(Map.from_struct(check))   

    # Refresh check and confirm running again wont notify again
    {:ok, check} = Check.get_by_id(check.id)
    Notification.do_notification(Map.from_struct(check)) 

    # Refresh check and confirm running again wont notify again
    {:ok, check} = Check.get_by_id(check.id)
    Notification.do_notification(Map.from_struct(check)) 

    # Refresh check and confirm running again wont notify again
    {:ok, check} = Check.get_by_id(check.id)
    Notification.do_notification(Map.from_struct(check)) 

    # Refresh check and confirm running again wont notify again
    {:ok, check} = Check.get_by_id(check.id)
    Notification.do_notification(Map.from_struct(check)) 

    # Refresh check and confirm running again wont notify again
    {:ok, check} = Check.get_by_id(check.id)
    Notification.do_notification(Map.from_struct(check)) 
  end
end