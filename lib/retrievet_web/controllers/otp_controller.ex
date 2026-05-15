defmodule RetrievetWeb.OtpController do
  use RetrievetWeb, :controller
  alias Retrievet.Accounts

  def send_otp(conn, %{"cp_number" => cp_number}) do
    otp = (:rand.uniform(899_999) + 100_000) |> Integer.to_string()

    case Accounts.set_otp(cp_number, otp) do
      {:ok, _user} ->
        # Here you would send the OTP via SMS using an external service
        # For mailbox preview, just show the OTP in the response
        json(conn, %{status: "ok", otp: otp})

      {:error, :not_found} ->
        json(conn, %{status: "error", error: "User not found"})

      _ ->
        json(conn, %{status: "error", error: "Server error"})
    end
  end

  def verify_otp(conn, %{"cp_number" => cp_number, "otp" => otp}) do
    case Accounts.verify_otp(cp_number, otp) do
      {:ok, _user} ->
        json(conn, %{status: "ok"})

      {:error, :invalid_otp} ->
        json(conn, %{status: "error", error: "Invalid OTP"})

      {:error, :expired} ->
        json(conn, %{status: "error", error: "OTP expired"})

      _ ->
        json(conn, %{status: "error", error: "Server error"})
    end
  end
end
