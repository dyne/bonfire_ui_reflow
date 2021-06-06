defmodule Bonfire.UI.Reflow.ProcessesLive do
  use Bonfire.Web, :live_view
  # use Surface.LiveView
  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.UI.Social.{HashtagsLive, ParticipantsLive}
  alias Bonfire.UI.ValueFlows.{IntentCreateActivityLive, CreateMilestoneLive, ProposalFeedLive, FiltersLive}
  alias Bonfire.Web.LivePlugs
  alias Bonfire.Me.Users
  alias Bonfire.Me.Web.{CreateUserLive, LoggedDashboardLive}
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

    processes = processes(socket)
    IO.inspect(processes)

    {:ok, socket
    |> assign(
      page_title: "All lists",
      page: "processes",
      smart_input: false,
      processes: processes
    )}
  end

  @graphql """
  {
    processes {
      id
      name
      note
      has_end
      intended_outputs {
        finished
      }
    }
  }
  """
  def processes(params \\ %{}, socket), do: liveql(socket, :processes, params)
  defdelegate handle_params(params, attrs, socket), to: Bonfire.Common.LiveHandlers
  def handle_event(action, attrs, socket), do: Bonfire.Common.LiveHandlers.handle_event(action, attrs, socket, __MODULE__)
  def handle_info(info, socket), do: Bonfire.Common.LiveHandlers.handle_info(info, socket, __MODULE__)

end
