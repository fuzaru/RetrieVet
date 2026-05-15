defmodule RetrievetWeb.RegisterLive do
  use RetrievetWeb, :live_view

  alias Retrievet.Accounts

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: registration_form(), error: nil)}
  end

  def handle_event("validate", params, socket) do
    form = to_form(params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("register", %{"email" => email} = params, socket) do
    case Accounts.start_registration(params) do
      {:ok, pending_registration} ->
        token =
          Phoenix.Token.sign(socket.endpoint, "pending_registration", pending_registration.id)

        {:noreply,
         socket
         |> put_flash(:info, "An OTP has been sent to #{email}.")
         |> push_navigate(to: ~p"/register/verify/#{token}")}

      {:error, changeset} ->
        {:noreply, assign(socket, error: registration_error(changeset))}

      _ ->
        {:noreply, assign(socket, error: "Server error. Please try again.")}
    end
  end

  defp registration_form do
    to_form(%{
      "email" => "",
      "password" => "",
      "first_name" => "",
      "last_name" => "",
      "cp_number" => ""
    })
  end

  defp registration_error(changeset) do
    cond do
      match?({"has already been taken", _}, changeset.errors[:email]) ->
        "Email already registered."

      match?({_, _}, changeset.errors[:password]) ->
        "Password must be at least 8 characters."

      match?({_, _}, changeset.errors[:first_name]) ->
        "First name is too short."

      match?({_, _}, changeset.errors[:last_name]) ->
        "Last name is too short."

      match?({_, _}, changeset.errors[:cp_number]) ->
        "Cellphone number must be a valid PH mobile (09XXXXXXXXX)."

      true ->
        "Invalid input. Please check your details."
    end
  end
end
