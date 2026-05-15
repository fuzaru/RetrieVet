defmodule Retrievet.OTPMail do
  @moduledoc """
  Builds OTP email messages.
  """

  import Swoosh.Email

  def otp_email(user, otp) do
    new()
    |> to({user.first_name <> " " <> user.last_name, user.email})
    |> from({"RetrieVet", "no-reply@retrievet.local"})
    |> subject("Your RetrieVet OTP Code")
    |> text_body("Your OTP code is: #{otp}\nThis code will expire in 10 minutes.")
  end
end
