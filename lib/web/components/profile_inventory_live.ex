defmodule Bonfire.UI.Reflow.ProfileInventoryLive do
  use Bonfire.Web, :stateless_component
  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  prop user, :map
  prop resources, :map
  prop selected_tab, :string
  
  def update(assigns, socket) do

    resources = agent_resources(%{id: assigns.user.id}, socket)
    IO.inspect(resources)

    {:ok, socket
    |> assigns_merge( assigns, [
      resource_url_prefix: "/resource/",
      resources: e(resources, :agent, :inventoried_economic_resources, []),
    ]
    )}
  end

  @graphql """
  query($id: ID) {
  agent(id: $id) {
    inventoried_economic_resources {
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
    }
  }}
  """
  def agent_resources(params \\ %{}, socket), do: liveql(socket, :agent_resources, params)


end
