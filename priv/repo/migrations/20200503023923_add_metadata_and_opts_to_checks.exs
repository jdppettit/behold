defmodule :"Elixir.Behold.Repo.Migrations.Add metadata and opts to checks" do
  use Ecto.Migration

  def change do
    CheckOperationTypes.create_type

    alter table("checks") do
      add :name, :string
      add :operation, CheckOperationTypes.type()
      add :comparison, :string
    end
  end
end
