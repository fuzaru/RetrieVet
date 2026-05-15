defmodule Retrievet.Repo.Migrations.AddIndexToUsersCpNumber do
  use Ecto.Migration

  def change do
    create index(:users, [:cp_number])
  end
end
