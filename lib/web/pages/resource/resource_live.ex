defmodule Bonfire.UI.Reflow.ResourceLive do
  use Bonfire.Web, :surface_view
  # use Surface.LiveView
  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.UI.Social.{HashtagsLive, ParticipantsLive}
  alias Bonfire.UI.ValueFlows.{IntentCreateActivityLive, CreateMilestoneLive, ProposalFeedLive, FiltersLive}
  alias Bonfire.Web.LivePlugs
  alias Bonfire.Me.Users
  alias Bonfire.Me.Web.{CreateUserLive, LoggedDashboardLive}
  # alias Bonfire.UI.Reflow.ResourceWidget

  @recurse_limit 10

  def mount(params, session, socket) do

    # IO.inspect(pre_plugs: socket)

    LivePlugs.live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      LivePlugs.StaticChanged,
      LivePlugs.Csrf, LivePlugs.Locale,
      &mounted/3,
    ]
  end

  defp mounted(%{"id"=> id} = _params, _session, socket) do
    # IO.inspect(post_plugs: socket)

    resource = economic_resource(%{id: id}, socket)
    # IO.inspect(resource: resource)

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

  @resource_fields_basic """
    id
    name
    note
    image
    primary_accountable
    onhand_quantity {
      id
      has_numerical_value
      has_unit {
        label
        symbol
      }
    }
  """

  @track_trace """
  (recurse_limit: #{@recurse_limit}){
      __typename
      ...on EconomicEvent {#{Bonfire.UI.Reflow.ProcessLive.event_fields_basic}}
      ...on EconomicResource {#{@resource_fields_basic}}
      ...on Process {#{Bonfire.UI.Reflow.ProcessLive.process_fields_basic}}
    }
  """

  @graphql """
  query($id: ID) {
    economic_resource(id: $id) {
      #{@resource_fields_basic}
      current_location {
        id
        name
        mappable_address
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
      track#{@track_trace}
      trace#{@track_trace}
    }
  }
  """
  def economic_resource(params \\ %{}, socket), do: liveql(socket, :economic_resource, params)

  # FIXME: looks like we can't have multiple liveql queries in same module?
  # @graphql """
  # query($id: ID) {
  #   economic_resource(id: $id) {
  #     track #{Bonfire.UI.Reflow.ProcessLive.event_fields}
  #   }
  # }
  # """
  # def track(params \\ %{}, socket), do: liveql(socket, :economic_resource, params)

  # @graphql """
  # query($id: ID) {
  #   economic_resource(id: $id) {
  #     trace #{Bonfire.UI.Reflow.ProcessLive.event_fields}
  #   }
  # }
  # """
  # def trace(params \\ %{}, socket), do: liveql(socket, :economic_resource, params)


  def handle_params(%{"tab"=>"track"}, attrs, socket) do
    resource = e(socket.assigns, :resource, nil)

    if resource do
      # resource = track(%{id: id}, socket)
      # IO.inspect(track: resource)

      {:noreply, socket
      |> assign(
        selected_tab: "track",
        feed: e(resource, :track, []) |> IO.inspect(label: "track")
      )}
    end
  end

  def handle_params(_, attrs, socket) do
    resource = e(socket.assigns, :resource, nil)

    if resource do
      # resource = trace(%{id: id}, socket)
      # IO.inspect(trace: resource)

      {:noreply, socket
      |> assign(
        selected_tab: "trace",
        feed: e(resource, :trace, []) #|> IO.inspect(label: "trace")
      )}
    end
  end

  defdelegate handle_params(params, attrs, socket), to: Bonfire.Common.LiveHandlers
  def handle_event(action, attrs, socket), do: Bonfire.Common.LiveHandlers.handle_event(action, attrs, socket, __MODULE__)
  def handle_info(info, socket), do: Bonfire.Common.LiveHandlers.handle_info(info, socket, __MODULE__)

end
