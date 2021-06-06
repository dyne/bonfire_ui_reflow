defmodule Bonfire.UI.Reflow.ProcessLive do
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

    LivePlugs.live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      LivePlugs.StaticChanged,
      LivePlugs.Csrf, LivePlugs.Locale,
      &mounted/3,
    ]
  end

  defp mounted(%{"id"=> id} = _params, _session, socket) do

    {:ok, socket
    |> assign(
      page_title: "process",
      page: "process",
      selected_tab: "events",
      smart_input: false,
      process: process(%{id: id}, socket) |> IO.inspect()
      # resource: resource,
    )}
  end

  @process_fields_basic """
  id
  name
  note
  has_end
  finished
  """

  @agent_fields """
  {
    id
    name
    image
    display_username
  }
  """

  @quantity_fields """
  {
    has_numerical_value
    has_unit {
      label
      symbol
    }
  }
  """

  @resource_fields """
  {
    id
    name
    note
    image
    onhand_quantity #{@quantity_fields}
    accounting_quantity #{@quantity_fields}
  }
  """

  @event_fields_basic """
    id
    __typename
    note
    provider #{@agent_fields}
    receiver #{@agent_fields}
    action {
      label
    }
    resource_quantity {
      has_numerical_value
      has_unit {
        label
        symbol
      }
    }

    resource_inventoried_as #{@resource_fields}
    to_resource_inventoried_as #{@resource_fields}
  """

  @event_fields """
  {
    #{@event_fields_basic}

    effort_quantity {
      has_numerical_value
      has_unit {
        label
        symbol
      }
    }

    output_of
    input_of
  }
  """

  def process_fields_basic, do: @process_fields_basic
  def event_fields_basic, do: @event_fields_basic
  def event_fields, do: @event_fields

  @graphql """
    query($id: ID) {
      process(id: $id) {
        #{@process_fields_basic}
        outputs #{@event_fields}
      }
    }
  """
  def process(params \\ %{}, socket), do: liveql(socket, :process, params)


  defdelegate handle_params(params, attrs, socket), to: Bonfire.Common.LiveHandlers
  def handle_event(action, attrs, socket), do: Bonfire.Common.LiveHandlers.handle_event(action, attrs, socket, __MODULE__)
  def handle_info(info, socket), do: Bonfire.Common.LiveHandlers.handle_info(info, socket, __MODULE__)

end
