defmodule Retrievet.AccountsTest do
  use Retrievet.DataCase, async: true

  alias Retrievet.Accounts
  alias Retrievet.Accounts.PendingRegistration
  alias Retrievet.Repo

  import Swoosh.TestAssertions

  @valid_attrs %{
    email: "test@example.com",
    password: "supersecret123",
    first_name: "John",
    last_name: "Doe",
    cp_number: "09123456789"
  }
  @invalid_email_attrs %{
    email: "bademail",
    password: "supersecret123",
    first_name: "John",
    last_name: "Doe",
    cp_number: "09123456789"
  }
  @short_password_attrs %{
    email: "test2@example.com",
    password: "short",
    first_name: "John",
    last_name: "Doe",
    cp_number: "09123456789"
  }

  test "register_user/1 with valid data creates a user" do
    assert {:ok, user} = Accounts.register_user(@valid_attrs)
    assert user.email == "test@example.com"
    assert user.password_hash
  end

  test "register_user/1 with invalid email returns error changeset" do
    assert {:error, changeset} = Accounts.register_user(@invalid_email_attrs)
    assert %{email: ["has invalid format"]} = errors_on(changeset)
  end

  test "register_user/1 with short password returns error changeset" do
    assert {:error, changeset} = Accounts.register_user(@short_password_attrs)
    assert %{password: ["should be at least 8 character(s)"]} = errors_on(changeset)
  end

  test "register_user/1 with duplicate email returns error changeset" do
    duplicate_attrs = Map.put(@valid_attrs, :cp_number, "09123456780")

    Accounts.register_user(@valid_attrs)
    assert {:error, changeset} = Accounts.register_user(duplicate_attrs)
    assert %{email: ["has already been taken"]} = errors_on(changeset)
  end

  test "register_user/1 with duplicate cellphone number returns error changeset" do
    duplicate_attrs = Map.put(@valid_attrs, :email, "second@example.com")

    assert {:ok, _user} = Accounts.register_user(@valid_attrs)
    assert {:error, changeset} = Accounts.register_user(duplicate_attrs)
    assert %{cp_number: ["has already been taken"]} = errors_on(changeset)
  end

  test "start_registration/1 sends an OTP email without creating a user" do
    assert {:ok, pending_registration} = Accounts.start_registration(@valid_attrs)

    assert pending_registration.email == @valid_attrs.email
    assert pending_registration.otp
    assert Accounts.get_user_by_email(@valid_attrs.email) == nil

    assert_email_sent(to: {full_name(@valid_attrs), @valid_attrs.email})
  end

  test "verify_pending_registration/2 creates the user after a valid OTP" do
    assert {:ok, pending_registration} = Accounts.start_registration(@valid_attrs)

    assert {:ok, user} =
             Accounts.verify_pending_registration(
               pending_registration.id,
               pending_registration.otp
             )

    assert user.email == @valid_attrs.email
    assert user.otp_verified
    assert Repo.get(PendingRegistration, pending_registration.id) == nil
  end

  test "verify_pending_registration/2 rejects an invalid OTP without creating a user" do
    assert {:ok, pending_registration} = Accounts.start_registration(@valid_attrs)

    assert {:error, :invalid_otp} =
             Accounts.verify_pending_registration(pending_registration.id, "000000")

    assert Accounts.get_user_by_email(@valid_attrs.email) == nil
  end

  test "authenticate_user/2 with valid credentials returns user" do
    {:ok, user} = Accounts.register_user(@valid_attrs)

    assert {:ok, auth_user} =
             Accounts.authenticate_user(@valid_attrs.email, @valid_attrs.password)

    assert auth_user.id == user.id
    assert auth_user.email == user.email
  end

  test "authenticate_user/2 with invalid password increments attempts and returns error" do
    {:ok, _user} = Accounts.register_user(@valid_attrs)

    assert {:error, :invalid_credentials} =
             Accounts.authenticate_user(@valid_attrs.email, "wrongpass")

    user = Accounts.get_user_by_email(@valid_attrs.email)
    assert user.attempts == 1
  end

  test "authenticate_user/2 with too many attempts returns rate limit error" do
    {:ok, _user} = Accounts.register_user(@valid_attrs)

    for _ <- 1..5 do
      Accounts.authenticate_user(@valid_attrs.email, "wrongpass")
    end

    assert {:error, :too_many_attempts} =
             Accounts.authenticate_user(@valid_attrs.email, "wrongpass")
  end

  defp full_name(attrs), do: attrs.first_name <> " " <> attrs.last_name
end
