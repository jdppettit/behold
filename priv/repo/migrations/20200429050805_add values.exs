defmodule :"Elixir.Behold.Repo.Migrations.Add values" do
  use Ecto.Migration

  def change do
    ValueType.create_type

    create table("values") do
      add :value, ValueType.type()
      add :check_id, references("checks")

      timestamps()
    end
  end
end
