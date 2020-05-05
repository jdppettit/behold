defmodule AlertType do
  use EctoEnum,
    type: :alert_type,
    enums: [
      :email,
      :phone,
      :sms,
      :webhook
    ]
end
