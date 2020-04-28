defmodule CheckTypes do
  use EctoEnum, type: :check_type, enums: [:http, :ping, :http_json]
end
