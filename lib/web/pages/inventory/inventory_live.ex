defmodule Bonfire.UI.Reflow.InventoryLive do
  use Bonfire.Web, :live_view
  # use Surface.LiveView
  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.Web.LivePlugs
  alias Bonfire.Me.Users

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
    resources = agent_resources(%{id: e(current_user(socket), :id, nil)}, socket)
    # IO.inspect(Jason.encode!(resources))
    # IO.inspect(resources)

    {:ok, socket
    |> assign(
      page_title: "My inventory",
      resource_url_prefix: "/resource/",
      page: "inventory",
      smart_input: false,
      resources: e(resources, :agent, :inventoried_economic_resources, [])
    )}
  end


  @graphql """
  query($id: ID) {
  agent(id: $id) {
    inventoried_economic_resources {
      __typename
      id
      name
      note
      image
      current_location {
        __typename
        id
        name
        mappable_address
      }
      onhand_quantity {
        __typename
        id
        has_numerical_value
        has_unit {
          label
          symbol
        }
      }
    }
  }}
  """
  def agent_resources(params \\ %{}, socket), do: liveql(socket, :agent_resources, params)


end
