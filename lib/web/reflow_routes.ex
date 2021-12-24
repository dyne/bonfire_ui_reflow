defmodule Bonfire.UI.Reflow.Routes do
  defmacro __using__(_) do

    quote do

      # pages anyone can view
      scope "/", Bonfire.UI.Reflow do
        pipe_through :browser
        live "/resource/:id", ResourceLive, as: ValueFlows.EconomicResource
        live "/resource/:id/:tab", ResourceLive
        live "/process/:id", ProcessLive, as: ValueFlows.Process
        live "/process/:id/:tab", ProcessLive
        live "/processes", ProcessesLive
        live "/materials", MaterialsLive
        live "/inventory", InventoryLive
        live "/reflow/map", MapLive
      end

    end
  end
end
