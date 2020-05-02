defmodule Behold.Repo.Migrations.AddCheckState do
  use Ecto.Migration

  def change do
    CheckStateTypes.create_type

    alter table(:checks) do
      add :state, CheckStateTypes.type()
    end
  end
end
