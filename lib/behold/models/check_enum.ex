defmodule CheckTypes do
  use EctoEnum, type: :check_type, enums: [:http, :ping, :http_json]
end

defmodule CheckStateTypes do
  use EctoEnum, type: :check_state_Type, enums: [:nominal, :warning, :critical]
end
