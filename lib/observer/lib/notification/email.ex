defmodule Observer.Notification.EmailBehaviour do
 @callback send(check::Map, alert::Map, type::Atom) :: {:ok, term()}
end

defmodule Observer.Notification.Email do
  require Logger

  @from Application.get_env(:observer, :email_notification_from, "behold@example.com")

  import Bamboo.Email

  @impl Observer.Notification.EmailBehaviour
  def send(check, alert, :down) do
    new_email(
      to: alert.target,
      from: @from,
      subject: "[Behold Monitoring]: #{check.name} is DOWN",
      html_body: 
      """
      <p>Name: #{check.name}</p>
      <p>Target: #{check.target}</p>
      <p>Type: #{check.type}</p>
      <p>ID: #{check.id}</p>
      <p>
        Depending on your alert settings you will continue to be notified
        until resolution or will only receive another notificaiton once
        the issue has resolved.
      </p>
      """,
      text_body: 
      """
      Name: #{check.name}
      Target: #{check.target}
      Type: #{check.type}
      ID: #{check.id}
      
      Depending on your alert settings you will continue to be notified
      until resolution or will only receive another notificaiton once
      the issue has resolved.
      """
    )
    |> Observer.Common.Mailer.deliver_now()
  end

  @impl Observer.Notification.EmailBehaviour
  def send(check, alert, :up) do
    new_email(
      to: alert.target,
      from: @from,
      subject: "[Behold Monitoring]: #{check.name} has RECOVERED",
      html_body: 
      """
      <p>Name: #{check.name}</p>
      <p>Target: #{check.target}</p>
      <p>Type: #{check.type}</p>
      <p>ID: #{check.id}</p>
      """,
      text_body: 
      """
      Name: #{check.name}
      Target: #{check.target}
      Type: #{check.type}
      ID: #{check.id}
      """
    )
    |> Observer.Common.Mailer.deliver_now()
  end
end
