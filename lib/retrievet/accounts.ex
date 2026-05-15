defmodule Retrievet.Accounts do
  @moduledoc """
  User registration, authentication, and OTP verification.
  """

  import Ecto.Query

  alias Ecto.Changeset
  alias Retrievet.Accounts.PendingRegistration
  alias Retrievet.Accounts.User
  alias Retrievet.{Mailer, OTPMail, Repo}

  @max_attempts 5
  @rate_limit_seconds 60
  @otp_ttl_seconds 600

  def get_user_by_cp_number(cp_number) do
    User
    |> where([user], user.cp_number == ^cp_number)
    |> order_by([user], desc: user.inserted_at, desc: user.id)
    |> limit(1)
    |> Repo.one()
  end

  def set_otp(cp_number, otp) do
    case get_user_by_cp_number(cp_number) do
      nil ->
        {:error, :not_found}

      user ->
        now = DateTime.truncate(DateTime.utc_now(), :second)

        changeset =
          Ecto.Changeset.change(user, %{otp: otp, otp_sent_at: now, otp_verified: false})

        case Repo.update(changeset) do
          {:ok, updated_user} ->
            email = OTPMail.otp_email(updated_user, otp)
            Mailer.deliver(email)
            {:ok, updated_user}

          error ->
            error
        end
    end
  end

  def get_pending_registration(id), do: Repo.get(PendingRegistration, id)

  def start_registration(attrs) do
    changeset = User.registration_changeset(%User{}, attrs)

    if changeset.valid? do
      changeset
      |> Changeset.apply_changes()
      |> create_pending_registration()
    else
      {:error, changeset}
    end
  end

  def verify_pending_registration(id, otp) do
    case get_pending_registration(id) do
      nil ->
        {:error, :not_found}

      pending_registration ->
        cond do
          pending_registration.otp != otp ->
            {:error, :invalid_otp}

          otp_expired?(pending_registration) ->
            {:error, :expired}

          true ->
            create_verified_user(pending_registration)
        end
    end
  end

  def verify_otp(cp_number, otp) do
    case get_user_by_cp_number(cp_number) do
      nil ->
        {:error, :not_found}

      user ->
        cond do
          user.otp_verified ->
            {:ok, user}

          user.otp != otp ->
            {:error, :invalid_otp}

          otp_expired?(user) ->
            {:error, :expired}

          true ->
            user
            |> Ecto.Changeset.change(%{otp_verified: true})
            |> Repo.update()
        end
    end
  end

  defp otp_expired?(user) do
    user.otp_sent_at && DateTime.diff(DateTime.utc_now(), user.otp_sent_at) > @otp_ttl_seconds
  end

  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  defp create_pending_registration(user) do
    otp = generate_otp()
    now = DateTime.truncate(DateTime.utc_now(), :second)

    attrs = %{
      email: user.email,
      password_hash: user.password_hash,
      first_name: user.first_name,
      last_name: user.last_name,
      cp_number: user.cp_number,
      otp: otp,
      otp_sent_at: now
    }

    Repo.transaction(fn ->
      from(pending_registration in PendingRegistration,
        where:
          pending_registration.email == ^user.email or
            pending_registration.cp_number == ^user.cp_number
      )
      |> Repo.delete_all()

      with {:ok, pending_registration} <-
             %PendingRegistration{}
             |> PendingRegistration.changeset(attrs)
             |> Repo.insert(),
           {:ok, _metadata} <- deliver_otp(pending_registration, otp) do
        pending_registration
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  defp create_verified_user(pending_registration) do
    attrs = %{
      email: pending_registration.email,
      password_hash: pending_registration.password_hash,
      first_name: pending_registration.first_name,
      last_name: pending_registration.last_name,
      cp_number: pending_registration.cp_number,
      otp: pending_registration.otp,
      otp_sent_at: pending_registration.otp_sent_at,
      otp_verified: true
    }

    Repo.transaction(fn ->
      with {:ok, user} <-
             %User{}
             |> User.verified_registration_changeset(attrs)
             |> Repo.insert(),
           {:ok, _pending_registration} <- Repo.delete(pending_registration) do
        user
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  defp deliver_otp(registration, otp) do
    registration
    |> OTPMail.otp_email(otp)
    |> Mailer.deliver()
  end

  defp generate_otp do
    (:rand.uniform(899_999) + 100_000) |> Integer.to_string()
  end

  def authenticate_user(email, password) do
    user = get_user_by_email(email)

    cond do
      user == nil ->
        {:error, :invalid_credentials}

      user.attempts >= @max_attempts and not expired_rate_limit?(user) ->
        {:error, :too_many_attempts}

      Bcrypt.verify_pass(password, user.password_hash) ->
        reset_attempts(user)
        {:ok, user}

      true ->
        increment_attempts(user)
        {:error, :invalid_credentials}
    end
  end

  defp expired_rate_limit?(user) do
    user.last_attempt_at &&
      DateTime.diff(DateTime.utc_now(), user.last_attempt_at) > @rate_limit_seconds
  end

  defp reset_attempts(user) do
    user
    |> Ecto.Changeset.change(%{attempts: 0, last_attempt_at: nil})
    |> Repo.update()
  end

  defp increment_attempts(user) do
    now = DateTime.truncate(DateTime.utc_now(), :second)

    user
    |> Ecto.Changeset.change(%{attempts: user.attempts + 1, last_attempt_at: now})
    |> Repo.update()
  end
end
