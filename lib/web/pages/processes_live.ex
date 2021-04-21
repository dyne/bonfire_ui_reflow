defmodule Bonfire.UI.Reflow.ProcessesLive do
  use Bonfire.Web, {:live_view, [layout: {Bonfire.UI.Reflow.LayoutView, "live.html"}]}

  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

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
    processes = all_processes(socket)

    {:ok, socket
    |> assign(
      page_title: "Milestones list",
      list: processes
    )}
  end


  @graphql """
    {
      processes {
        id
        name
        note
      }
    }
  """
  def processes(params \\ %{}, socket), do: liveql(socket, :processes, params)
  def all_processes(socket), do: processes(socket)


end
