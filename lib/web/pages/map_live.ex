defmodule Bonfire.UI.Reflow.MapLive do
  use Bonfire.Web, {:live_view, [layout: {Bonfire.UI.Reflow.LayoutView, "live.html"}]}

  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.Web.LivePlugs

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
    # intents = Bonfire.UI.Reflow.ProposalLive.all_intents(socket)
    #IO.inspect(intents)

    {:ok, socket
    |> assign(
      page_title: "Map",
      selected_tab: "about",
      markers: [],
      points: [],
      place: nil,
      main_labels: []
    )}
  end

  def fetch_place_things(filters, socket) do
    with {:ok, things} <-
           ValueFlows.Planning.Intent.Intents.many(filters) do
      IO.inspect(things)

      things =
        things
        |> Enum.map(
          &Map.merge(
            Bonfire.Geolocate.Geolocations.populate_coordinates(Map.get(&1, :at_location)),
            &1 || %{}
          )
        )

      IO.inspect(things)

      things
    else
      e ->
        IO.inspect(error: e)
        nil
    end
  end

  # proxy relevent events to the map component
  def handle_event("map_"<>_action = event, params, socket) do
    IO.inspect(proxy_event: event)
    IO.inspect(proxy_params: params)
    Bonfire.Geolocate.MapLive.handle_event(event, params, socket, true)
  end

end
