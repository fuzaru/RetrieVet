defmodule Retrievet.Repo.Migrations.AddUserFieldsAndOtp do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :cp_number, :string
      add :otp, :string
      add :otp_sent_at, :utc_datetime
      add :otp_verified, :boolean, default: false
    end
  end
end
