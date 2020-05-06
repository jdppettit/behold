defmodule Observer.Notification.Email do
  require Logger

  import Bamboo.Email

  def send(check, alert) do
    new_email(
      to: alert.target,
      from: "behold@example.com",
      subject: "Behold Monitoring: Check for #{check.target} is #{check.state}",
      html_body: "The check has failed.",
      text_body: "The check has failed."
    )
    |> Observer.Common.Mailer.deliver_now()
  end
end
