defmodule Behold.Repo.Migrations.AddIntervalToAlerts do
  use Ecto.Migration

  def change do
    alter table("alerts") do
      add :interval, :integer
    end
  end
end
