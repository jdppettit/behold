defmodule Behold.Repo.Migrations.AddLogs do
  use Ecto.Migration

  def change do
    LogTypes.create_type
    LogTargetTypes.create_type

    create table("logs") do
      add :type, LogTypes.type()
      add :result, :string
      add :target_id, :integer
      add :target_type, LogTargetTypes.type()

      timestamps()
    end
  end
end
