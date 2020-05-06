defmodule Elixir.Behold.Repo.Migrations.AddCheckIdToAlert do
  use Ecto.Migration

  def change do
    alter table("alerts") do
      add :check_id, references("checks")
    end
  end
end
