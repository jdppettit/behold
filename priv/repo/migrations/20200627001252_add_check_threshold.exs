defmodule Behold.Repo.Migrations.AddCheckThreshold do
  use Ecto.Migration

  def change do
    alter table("checks") do
      add :threshold, :integer, default: 3
    end
  end
end
