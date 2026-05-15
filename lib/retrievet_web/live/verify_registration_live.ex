defmodule RetrievetWeb.VerifyRegistrationLive do
  use RetrievetWeb, :live_view

  alias Retrievet.Accounts

  @token_salt "pending_registration"
  @max_token_age_seconds 600

  def mount(%{"token" => token}, _session, socket) do
    {:ok, assign_pending_registration(socket, token)}
  end

  def handle_event("validate", params, socket) do
    {:noreply, assign(socket, form: to_form(params), error: nil)}
  end

  def handle_event("verify", %{"otp" => otp}, socket) do
    case Accounts.verify_pending_registration(socket.assigns.pending_registration_id, otp) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Your account has been verified.")
         |> push_navigate(to: ~p"/")}

      {:error, :invalid_otp} ->
        {:noreply, assign(socket, error: "Invalid OTP. Please check the code and try again.")}

      {:error, :expired} ->
        {:noreply, assign(socket, error: "This OTP has expired. Please register again.")}

      _ ->
        {:noreply, assign(socket, error: "Verification failed. Please register again.")}
    end
  end

  defp assign_pending_registration(socket, token) do
    with {:ok, id} <-
           Phoenix.Token.verify(socket.endpoint, @token_salt, token,
             max_age: @max_token_age_seconds
           ),
         pending_registration when not is_nil(pending_registration) <-
           Accounts.get_pending_registration(id) do
      assign(socket,
        token_valid?: true,
        pending_registration_id: pending_registration.id,
        pending_email: pending_registration.email,
        form: verification_form(),
        error: nil
      )
    else
      _ ->
        assign(socket,
          token_valid?: false,
          pending_registration_id: nil,
          pending_email: nil,
          form: verification_form(),
          error: "This verification link is invalid or expired."
        )
    end
  end

  defp verification_form do
    to_form(%{"otp" => ""})
  end
end
