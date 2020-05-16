defmodule Behold.Repo.Migrations.AddReturnValueToValueRecord do
  use Ecto.Migration

  def change do
    alter table("values") do
      add :returned_value, :string
    end
  end
end
