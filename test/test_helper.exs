Mox.defmock(EmailNotificationMock, for: Observer.Notification.EmailBehaviour)

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Behold.Repo, :manual)

