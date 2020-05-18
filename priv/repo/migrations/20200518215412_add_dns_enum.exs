defmodule Behold.Repo.Migrations.AddDnsEnum do
  use Ecto.Migration

  def change do
    execute "alter type check_type add value 'dns';"
  end
end
