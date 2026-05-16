defmodule RetrievetWeb.LoginLive do
  use RetrievetWeb, :live_view
  alias Retrievet.Accounts

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{"email" => "", "password" => ""}), error: nil)}
  end

  def handle_event("validate", %{"email" => email, "password" => password}, socket) do
    form = to_form(%{"email" => email, "password" => password})
    {:noreply, assign(socket, form: form)}
  end

  def handle_event("login", %{"email" => email, "password" => password}, socket) do
    case Accounts.authenticate_user(email, password) do
      {:ok, _user} ->
        {:noreply, push_navigate(socket, to: ~p"/dashboard")}

      {:error, :too_many_attempts} ->
        {:noreply, assign(socket, error: "Too many failed attempts. Please try again later.")}

      {:error, :invalid_credentials} ->
        {:noreply, assign(socket, error: "Invalid email or password.")}

      _ ->
        {:noreply, assign(socket, error: "Server error. Please try again.")}
    end
  end
end
