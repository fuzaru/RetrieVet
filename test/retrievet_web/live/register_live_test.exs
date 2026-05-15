defmodule RetrievetWeb.RegisterLiveTest do
  use RetrievetWeb.ConnCase, async: true

  alias Retrievet.Accounts

  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions

  @valid_attrs %{
    "email" => "live@example.com",
    "password" => "supersecret123",
    "first_name" => "Live",
    "last_name" => "User",
    "cp_number" => "09123456788"
  }

  test "renders registration form", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/register")

    assert has_element?(view, "#register-form")
  end

  test "register redirects to OTP verification and sends an email", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/register")

    view
    |> form("#register-form", @valid_attrs)
    |> render_submit()

    assert {path, _flash} = assert_redirect(view)
    assert path =~ "/register/verify/"
    assert Accounts.get_user_by_email(@valid_attrs["email"]) == nil
    assert_email_sent(to: {"Live User", @valid_attrs["email"]})
  end

  test "OTP verification creates the user and redirects home", %{conn: conn} do
    {:ok, pending_registration} = Accounts.start_registration(@valid_attrs)

    token =
      Phoenix.Token.sign(RetrievetWeb.Endpoint, "pending_registration", pending_registration.id)

    {:ok, view, _html} = live(conn, ~p"/register/verify/#{token}")

    view
    |> form("#otp-verification-form", %{"otp" => pending_registration.otp})
    |> render_submit()

    assert_redirect(view, ~p"/")
    assert Accounts.get_user_by_email(@valid_attrs["email"])
  end

  test "OTP verification shows an error for invalid OTP", %{conn: conn} do
    {:ok, pending_registration} = Accounts.start_registration(@valid_attrs)

    token =
      Phoenix.Token.sign(RetrievetWeb.Endpoint, "pending_registration", pending_registration.id)

    {:ok, view, _html} = live(conn, ~p"/register/verify/#{token}")

    view
    |> form("#otp-verification-form", %{"otp" => "000000"})
    |> render_submit()

    assert has_element?(view, "#otp-verification-error")
    assert Accounts.get_user_by_email(@valid_attrs["email"]) == nil
  end

  test "OTP verification shows a recovery link for an invalid token", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/register/verify/not-a-valid-token")

    refute has_element?(view, "#otp-verification-form")
    assert has_element?(view, "#otp-verification-error")
    assert has_element?(view, "#register-again-link")
  end
end
