defmodule Retrievet.Accounts.PendingRegistration do
  use Ecto.Schema

  import Ecto.Changeset

  schema "pending_registrations" do
    field :email, :string
    field :password_hash, :string
    field :first_name, :string
    field :last_name, :string
    field :cp_number, :string
    field :otp, :string
    field :otp_sent_at, :utc_datetime

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(pending_registration, attrs) do
    pending_registration
    |> cast(attrs, [
      :email,
      :password_hash,
      :first_name,
      :last_name,
      :cp_number,
      :otp,
      :otp_sent_at
    ])
    |> validate_required([
      :email,
      :password_hash,
      :first_name,
      :last_name,
      :cp_number,
      :otp,
      :otp_sent_at
    ])
    |> unique_constraint(:email)
    |> unique_constraint(:cp_number)
  end
end
