defmodule RetrievetWeb.OtpControllerTest do
  use RetrievetWeb.ConnCase, async: true

  alias Retrievet.Accounts

  import Swoosh.TestAssertions

  @valid_attrs %{
    email: "otp-controller@example.com",
    password: "supersecret123",
    first_name: "Otp",
    last_name: "User",
    cp_number: "09123456787"
  }

  test "POST /otp/send returns an OTP for an existing user", %{conn: conn} do
    assert {:ok, _user} = Accounts.register_user(@valid_attrs)

    conn = post(conn, ~p"/otp/send", %{"cp_number" => @valid_attrs.cp_number})

    assert %{"status" => "ok", "otp" => otp} = json_response(conn, 200)
    assert String.length(otp) == 6
    assert_email_sent(to: {full_name(@valid_attrs), @valid_attrs.email})
  end

  test "POST /otp/send returns an error for an unknown user", %{conn: conn} do
    conn = post(conn, ~p"/otp/send", %{"cp_number" => "09999999999"})

    assert %{"status" => "error", "error" => "User not found"} = json_response(conn, 200)
  end

  test "POST /otp/verify accepts the latest sent OTP", %{conn: conn} do
    assert {:ok, _user} = Accounts.register_user(@valid_attrs)
    assert {:ok, user} = Accounts.set_otp(@valid_attrs.cp_number, "123456")

    conn = post(conn, ~p"/otp/verify", %{"cp_number" => user.cp_number, "otp" => "123456"})

    assert %{"status" => "ok"} = json_response(conn, 200)
  end

  test "POST /otp/verify rejects an invalid OTP", %{conn: conn} do
    assert {:ok, _user} = Accounts.register_user(@valid_attrs)
    assert {:ok, user} = Accounts.set_otp(@valid_attrs.cp_number, "123456")

    conn = post(conn, ~p"/otp/verify", %{"cp_number" => user.cp_number, "otp" => "000000"})

    assert %{"status" => "error", "error" => "Invalid OTP"} = json_response(conn, 200)
  end

  defp full_name(attrs), do: attrs.first_name <> " " <> attrs.last_name
end
