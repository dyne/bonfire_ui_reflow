defmodule Bonfire.UI.Reflow.Routes do
  defmacro __using__(_) do

    quote do

      # pages anyone can view
      scope "/", Bonfire.UI.Reflow do
        pipe_through :browser
        live "/resource/:id", ResourceLive
        live "/process/:id", ProcessLive
        live "/process/:id/:tab", ProcessLive
        live "/reflow/map", MapLive
      end

    end
  end
end
