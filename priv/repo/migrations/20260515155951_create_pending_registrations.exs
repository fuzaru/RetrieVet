defmodule Retrievet.Repo.Migrations.CreatePendingRegistrations do
  use Ecto.Migration

  def change do
    create table(:pending_registrations) do
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :cp_number, :string, null: false
      add :otp, :string, null: false
      add :otp_sent_at, :utc_datetime, null: false

      timestamps(updated_at: false)
    end

    create unique_index(:pending_registrations, [:email])
    create unique_index(:pending_registrations, [:cp_number])
  end
end
