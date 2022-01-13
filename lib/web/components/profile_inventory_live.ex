defmodule Bonfire.UI.Reflow.ProfileInventoryLive do
  use Bonfire.Web, :stateless_component
  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  prop user, :map
  prop resources, :map
  prop selected_tab, :string

  def list_resources(user_id) do

    resources = agent_resources(%{id: user_id})
    # IO.inspect(agent_resources: resources)

    e(resources, :agent, :inventoried_economic_resources, [])
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
  def agent_resources(params \\ %{}, socket \\ nil), do: liveql(socket, :agent_resources, params)


end
