defmodule Bonfire.UI.Reflow.BreadDashboardLive do
  use Bonfire.Web, {:live_view, [layout: {Bonfire.UI.Reflow.LayoutView, "live.html"}]}

  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.UI.Social.{HashtagsLive, ParticipantsLive}
  alias Bonfire.UI.ValueFlows.{IntentCreateActivityLive, CreateMilestoneLive, ProposalFeedLive, FiltersLive}
  alias Bonfire.Web.LivePlugs
  alias Bonfire.Me.Users
  alias Bonfire.Me.Web.{CreateUserLive, LoggedDashboardLive}

  def mount(params, session, socket) do
    LivePlugs.live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      LivePlugs.StaticChanged,
      LivePlugs.Csrf,
      &mounted/3,
    ]
  end

  defp mounted(params, session, socket) do
    intents = all_intents(socket)
    IO.inspect(intents)

    {:ok, socket
    |> assign(
      page_title: "Home",
      selected_tab: "about",
      list: intents,
      main_labels: [
        %{id: 1, name: "Frontend dev", items: 5, color: "blue"},
        %{id: 2, name: "Backend dev", items: 0, color: "yellow"},
        %{id: 3, name: "AP dev", items: 1, color: "pink"},
        %{id: 4, name: "Content", items: 3, color: "red"}
      ]
    )}
  end

  def handle_info({:loc, location}, socket) do
    IO.inspect(location, label: "LOCATION:")
    {:noreply, socket}
  end


  @graphql """
    {
      intents {
        id
        name
        provider
        receiver
        at_location
      }
    }
  """
  def intents(params \\ %{}, socket), do: liveql(socket, :intents, params)
  def all_intents(socket), do: intents(socket)


end
