defmodule Behold.Repo.Migrations.AddCheckModel do
  use Ecto.Migration

  def change do
    CheckTypes.create_type

    create table("checks") do
      add :value, :string
      add :interval, :integer
      add :target, :string
      add :type, CheckTypes.type()

      timestamps()
    end
  end
end
