defmodule CheckTypes do
  use EctoEnum,
    type: :check_type,
    enums: [
      :http,
      :ping,
      :http_json,
      :http_json_comparison
    ]
end

defmodule CheckStateTypes do
  use EctoEnum,
    type: :check_state_Type,
    enums: [
      :nominal,
      :warning,
      :critical
    ]
end

defmodule CheckOperationTypes do
  use EctoEnum,
    type: :check_operation_types,
    enums: [
      :greater_than,
      :less_than,
      :greater_than_or_equal_to,
      :less_than_or_equal_to,
      :equal_to,
      :not_equal_to
    ]
end
