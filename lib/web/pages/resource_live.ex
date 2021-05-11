defmodule Bonfire.UI.Reflow.ResourceLive do
  use Bonfire.Web, :live_view
  # use Surface.LiveView
  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.UI.Social.{HashtagsLive, ParticipantsLive}
  alias Bonfire.UI.ValueFlows.{IntentCreateActivityLive, CreateMilestoneLive, ProposalFeedLive, FiltersLive}
  alias Bonfire.Web.LivePlugs
  alias Bonfire.Me.Users
  alias Bonfire.Me.Web.{CreateUserLive, LoggedDashboardLive}
  # alias Bonfire.UI.Reflow.ResourceWidget

  def mount(params, session, socket) do

    # IO.inspect(pre_plugs: socket)

    LivePlugs.live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      LivePlugs.StaticChanged,
      LivePlugs.Csrf,
      &mounted/3,
    ]
  end

  defp mounted(%{"id"=> id} = _params, _session, socket) do
    # IO.inspect(post_plugs: socket)

    resource = economic_resource(%{id: id}, socket)
    IO.inspect(resource)

    {:ok, socket
    |> assign(
      page_title: "resource",
      page: "Resource",
      selected_tab: "about",
      smart_input: false,
      # resource: "1234",
      resource: resource,
      main_labels: [
        %{id: 1, name: "Frontend dev", items: 5, color: "blue"},
        %{id: 2, name: "Backend dev", items: 0, color: "yellow"},
        %{id: 3, name: "AP dev", items: 1, color: "pink"},
        %{id: 4, name: "Content", items: 3, color: "red"}
      ]
    )}
  end

  @graphql """
  query($id: ID) {
    economic_resource(id: $id) {
      id
      name
      note
      image
      current_location {
        id
        name
        mappable_address
      }
      onhand_quantity {
        id
        has_numerical_value
        has_unit {
          label
          symbol
        }
      }
      conforms_to {
        id
        name
        note
        image
      }
      tags {
        __typename
        ...on Tag {
          id
          name
          summary
        }
        ...on Category {
          id
          name
          summary
        }
      }
    }
  }
  """
  def economic_resource(params \\ %{}, socket), do: liveql(socket, :economic_resource, params)

  defdelegate handle_params(params, attrs, socket), to: Bonfire.Web.LiveHandler
  def handle_event(action, attrs, socket), do: Bonfire.Web.LiveHandler.handle_event(action, attrs, socket, __MODULE__)
  def handle_info(info, socket), do: Bonfire.Web.LiveHandler.handle_info(info, socket, __MODULE__)

end
