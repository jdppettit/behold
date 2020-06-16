defmodule LogTypes do
  use EctoEnum,
    type: :log_type,
    enums: [
      :rollup_result,
      :check_result,
      :notification_result
    ]
end

defmodule LogTargetTypes do
  use EctoEnum,
    type: :log_target_type,
    enums: [
      :check,
      :notification
    ]
end
