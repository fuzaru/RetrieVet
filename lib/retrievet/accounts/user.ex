defmodule Retrievet.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Bcrypt
  alias Retrievet.Repo

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :first_name, :string
    field :last_name, :string
    field :cp_number, :string
    field :otp, :string
    field :otp_sent_at, :utc_datetime
    field :otp_verified, :boolean, default: false
    field :attempts, :integer, default: 0
    field :last_attempt_at, :utc_datetime
    timestamps()
  end

  @doc false

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :first_name, :last_name, :cp_number])
    |> validate_required([:email, :password, :first_name, :last_name, :cp_number])
    |> validate_format(:email, ~r/@/)
    |> unsafe_validate_unique(:email, Repo)
    |> unique_constraint(:email)
    |> validate_length(:password, min: 8)
    |> validate_length(:first_name, min: 2)
    |> validate_length(:last_name, min: 2)
    |> validate_format(:cp_number, ~r/^09\d{9}$/,
      message: "must be a valid PH mobile number (e.g. 09XXXXXXXXX)"
    )
    |> unsafe_validate_unique(:cp_number, Repo)
    |> put_password_hash()
  end

  def verified_registration_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :password_hash,
      :first_name,
      :last_name,
      :cp_number,
      :otp,
      :otp_sent_at,
      :otp_verified
    ])
    |> validate_required([:email, :password_hash, :first_name, :last_name, :cp_number])
    |> unique_constraint(:email)
  end

  defp put_password_hash(changeset) do
    if password = get_change(changeset, :password) do
      put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    else
      changeset
    end
  end
end
