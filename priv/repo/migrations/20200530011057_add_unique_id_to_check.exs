defmodule Behold.Repo.Migrations.AddUniqueIdToCheck do
  use Ecto.Migration

  def change do
    alter table("checks") do
      add :unique_id, :string
    end

    create unique_index(:checks, [:unique_id])
  end
end
