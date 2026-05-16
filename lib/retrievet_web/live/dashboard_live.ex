defmodule RetrievetWeb.DashboardLive do
  use RetrievetWeb, :live_view

  def mount(_params, _session, socket) do
    stats = [
      %{label: "Appointments today", value: "18", detail: "+4 from yesterday"},
      %{label: "Open consults", value: "7", detail: "2 need follow-up"},
      %{label: "Waiting owners", value: "12", detail: "3 marked urgent"},
      %{label: "Completion rate", value: "94%", detail: "Last 7 days"}
    ]

    queue = [
      %{time: "09:30", title: "Milo Chen", note: "Vaccination follow-up", status: "Ready"},
      %{time: "10:10", title: "Bailey Tan", note: "Cough and lethargy", status: "In triage"},
      %{time: "10:45", title: "Luna Reyes", note: "Post-op check-in", status: "Awaiting vet"}
    ]

    actions = [
      %{title: "Create booking", desc: "Add a new appointment and assign a provider."},
      %{title: "Review messages", desc: "Clear unread owner messages and requests."},
      %{title: "Open follow-up list", desc: "Check patients who need another touchpoint."}
    ]

    {:ok,
     socket
     |> assign(page_title: "Dashboard")
     |> assign(stats: stats)
     |> assign(queue: queue)
     |> assign(actions: actions)}
  end
end
