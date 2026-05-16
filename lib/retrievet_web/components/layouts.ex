defmodule RetrievetWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use RetrievetWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="relative min-h-screen overflow-hidden bg-[#07111f] text-slate-100">
      <div class="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_top_left,_rgba(16,185,129,0.24),_transparent_30%),radial-gradient(circle_at_top_right,_rgba(14,165,233,0.14),_transparent_26%),linear-gradient(180deg,_rgba(7,17,31,0.94),_rgba(7,17,31,1))]" />
      <div class="pointer-events-none absolute inset-0 opacity-30 [background-image:linear-gradient(rgba(148,163,184,0.09)_1px,transparent_1px),linear-gradient(90deg,rgba(148,163,184,0.09)_1px,transparent_1px)] [background-size:72px_72px]" />

      <header class="relative z-10">
        <div class="mx-auto flex w-full max-w-7xl items-center justify-between px-4 py-5 sm:px-6 lg:px-8">
          <a href="/" class="flex items-center gap-3">
            <div class="flex size-11 items-center justify-center rounded-2xl border border-white/10 bg-white/5 shadow-[0_0_0_1px_rgba(255,255,255,0.04)] backdrop-blur">
              <span class="text-lg font-semibold tracking-tight text-white">R</span>
            </div>
            <div>
              <p class="text-[11px] font-medium uppercase tracking-[0.35em] text-emerald-300/80">
                Global Care Network
              </p>
              <p class="text-sm font-semibold tracking-tight text-white">RetrieVet</p>
            </div>
          </a>

          <nav class="hidden items-center gap-8 text-sm text-slate-300 md:flex">
            <a href="#providers" class="transition hover:text-white">For Clinics</a>
            <a href="#contact" class="transition hover:text-white">Contact</a>
          </nav>

          <div class="flex items-center gap-3">
            <.theme_toggle />
            <.link
              navigate={~p"/register"}
              class="hidden rounded-full border border-emerald-400/25 bg-emerald-400/10 px-5 py-2 text-sm font-semibold text-emerald-100 transition hover:-translate-y-0.5 hover:border-emerald-300/50 hover:bg-emerald-400/15 md:inline-flex"
            >
              Get Started <.icon name="hero-arrow-right" class="ml-2 size-4" />
            </.link>
          </div>
        </div>
      </header>

      <main class="relative z-10">
        <div class="mx-auto w-full max-w-7xl px-4 pb-14 pt-10 sm:px-6 lg:px-8 lg:pt-16">
          {render_slot(@inner_block)}
        </div>
      </main>

      <footer class="relative z-10 border-t border-white/10">
        <div class="mx-auto flex w-full max-w-7xl flex-col gap-4 px-4 py-8 text-sm text-slate-400 sm:px-6 lg:flex-row lg:items-center lg:justify-between lg:px-8">
          <p>RetrieVet connects pet owners and clinics with a calmer, faster care experience.</p>
          <p id="contact">Built on Phoenix, tuned for a polished clinic-grade experience.</p>
        </div>
      </footer>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="relative flex flex-row items-center rounded-full border border-white/10 bg-white/5 p-1 backdrop-blur">
      <div class="absolute left-1 h-[calc(100%-0.5rem)] w-[calc(33.333%-0.25rem)] rounded-full border border-white/10 bg-white/10 transition-[left] [[data-theme=light]_&]:left-[calc(33.333%+0.125rem)] [[data-theme=dark]_&]:left-[calc(66.666%+0.125rem)]" />

      <button
        class="relative z-10 flex w-1/3 cursor-pointer justify-center p-2"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon
          name="hero-computer-desktop-micro"
          class="size-4 text-slate-300 opacity-80 hover:opacity-100"
        />
      </button>

      <button
        class="relative z-10 flex w-1/3 cursor-pointer justify-center p-2"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 text-slate-300 opacity-80 hover:opacity-100" />
      </button>

      <button
        class="relative z-10 flex w-1/3 cursor-pointer justify-center p-2"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 text-slate-300 opacity-80 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
