defmodule Bonfire.UI.Reflow.ProcessesLive do
  use Bonfire.Web, :live_view
  # use Surface.LiveView
  use AbsintheClient, schema: Bonfire.API.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.UI.Social.{HashtagsLive, ParticipantsLive}
  alias Bonfire.UI.ValueFlows.{IntentCreateActivityLive, CreateMilestoneLive, ProposalFeedLive, FiltersLive}
  alias Bonfire.Web.LivePlugs
  alias Bonfire.Me.Users
  alias Bonfire.Me.Web.CreateUserLive
  # alias Bonfire.UI.Coordination.ResourceWidget

  def mount(params, session, socket) do

    LivePlugs.live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      LivePlugs.StaticChanged,
      LivePlugs.Csrf, LivePlugs.Locale,
      &mounted/3,
    ]
  end

  defp mounted(_params, _session, socket) do

    {:ok, socket
    |> fetch()
    |> assign(
      page_title: "All Processes",
      page: "processes",
      smart_input: false
    )}
  end

  @graphql """
  query($after: Cursor, $limit: Int) {
    processes_pages(after: $after, limit: $limit) {
      page_info
      edges {
        __typename
        id
        name
        note
        has_end
        intended_outputs {
          finished
        }
      }
    }
  }
  """
  def processes_pages(params \\ %{}, socket), do: liveql(socket, :processes_pages, params)

  def fetch(params \\ %{}, socket) do
    %{edges: processes, page_info: page_info} = processes_pages(params, socket)
    |> IO.inspect

    socket
    |> assign(
      processes: (e(socket.assigns, :processes, []) ++ processes) |> Enum.uniq,
      page_info: page_info
    )
  end

  def handle_event("load-more", params, socket) do
    {:noreply,
      input_to_atoms(params)
      |> fetch(socket)
    }
  end

  def handle_event(action, attrs, socket), do: Bonfire.Common.LiveHandlers.handle_event(action, attrs, socket, __MODULE__)
  def handle_info(info, socket), do: Bonfire.Common.LiveHandlers.handle_info(info, socket, __MODULE__)
  defdelegate handle_params(params, attrs, socket), to: Bonfire.Common.LiveHandlers

end
