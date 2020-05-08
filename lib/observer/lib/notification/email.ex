defmodule Observer.Notification.Email do
  require Logger

  import Bamboo.Email

  def send(check, alert, :down) do
    new_email(
      to: alert.target,
      from: "behold@example.com",
      subject: "Behold Monitoring: Check for #{check.target} is #{check.state}",
      html_body: "The check has failed.",
      text_body: "The check has failed."
    )
    |> Observer.Common.Mailer.deliver_now()
  end

  def send(check, alert, :up) do
    new_email(
      to: alert.target,
      from: "behold@example.com",
      subject: "Behold Monitoring: Check for #{check.target} is #{check.state}",
      html_body: "The check has returned to normal.",
      text_body: "The check has returned to normal."
    )
    |> Observer.Common.Mailer.deliver_now()
  end
end
