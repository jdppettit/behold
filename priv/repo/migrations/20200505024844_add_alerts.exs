defmodule Behold.Repo.Migrations.AddAlerts do
  use Ecto.Migration

  def change do
    AlertType.create_type

    create table("alerts") do
      add :type, AlertType.type()
      add :target, :string
      add :last_sent, :utc_datetime

      timestamps()
    end
  end
end
