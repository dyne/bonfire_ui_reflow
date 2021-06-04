defmodule Bonfire.UI.Reflow.MapLive do
  use Bonfire.Web, :live_view

  alias Bonfire.Web.LivePlugs

  def mount(params, session, socket) do
    LivePlugs.live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      LivePlugs.StaticChanged,
      LivePlugs.Csrf, LivePlugs.Locale,
      &mounted/3,
    ]
  end

  defp mounted(params, session, socket) do
    # intents = Bonfire.UI.ValueFlows.ProposalLive.all_intents(socket)
    #IO.inspect(intents)

    {:ok, socket
    |> assign(
      page_title: "Map of events",
      page: "map",
      selected_tab: "about",
      places: fetch_resources_places(socket),
      fetch_place_things_fn: &Bonfire.UI.Reflow.MapLive.fetch_resources_places/2
    )}
  end


  def fetch_resources_places(filters \\ [], _socket) do
    with {:ok, things} <-
          ValueFlows.EconomicResource.EconomicResources.many([{:preload, :current_location}] ++ filters) do
      # IO.inspect(things)

        things
        |> Enum.map(
          &Map.merge(
            Map.get(&1, :current_location) || %{},
            &1
          )
        )
        |> Enum.filter(&Map.has_key?(&1, :geom))
        # |> IO.inspect(label: "fetch_place_things")

    else
      e ->
        IO.inspect(error: e)
        nil
    end
  end

  def fetch_events_places(filters \\ [], _socket) do
    with {:ok, things} <-
           ValueFlows.EconomicEvent.EconomicEvents.many([{:preload, :locations}] ++ filters) do
      # IO.inspect(things)

        things
        |> Enum.map(
          &Map.merge(
            Map.get(&1, :at_location) || Map.get(&1, :to_resource_inventoried_as) || Map.get(&1, :resource_inventoried_as) || %{},
            &1
          )
        )
        |> Enum.filter(&Map.has_key?(&1, :geom))
        # |> IO.inspect(label: "fetch_place_things")

    else
      e ->
        IO.inspect(error: e)
        nil
    end
  end

  # proxy relevent events to the map component # FIXME
  def handle_event("map_"<>_action = event, params, socket) do
    IO.inspect(proxy_event: event)
    IO.inspect(proxy_params: params)
    Bonfire.Geolocate.MapLive.handle_event(event, params, socket, true)
  end

  defdelegate handle_params(params, attrs, socket), to: Bonfire.Web.LiveHandler
  def handle_event(action, attrs, socket), do: Bonfire.Web.LiveHandler.handle_event(action, attrs, socket, __MODULE__)
  def handle_info(info, socket), do: Bonfire.Web.LiveHandler.handle_info(info, socket, __MODULE__)

end
