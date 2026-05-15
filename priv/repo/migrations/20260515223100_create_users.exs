defmodule Retrievet.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :attempts, :integer, default: 0
      add :last_attempt_at, :utc_datetime
      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
