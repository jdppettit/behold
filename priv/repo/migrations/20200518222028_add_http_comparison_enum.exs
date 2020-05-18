defmodule Behold.Repo.Migrations.AddHttpComparisonEnum do
  use Ecto.Migration

  def change do
    execute "alter type check_type add value 'http_comparison';"
  end
end
