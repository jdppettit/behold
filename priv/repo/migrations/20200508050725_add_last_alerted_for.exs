defmodule Behold.Repo.Migrations.AddLastAlertedFor do
  use Ecto.Migration

  def change do
    alter table("checks") do
      add :last_alerted_for, CheckStateTypes.type()
    end
  end
end
