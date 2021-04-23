defmodule Bonfire.UI.Reflow.Routes do
  defmacro __using__(_) do

    quote do

      alias Bonfire.UI.Reflow.Routes.Helpers, as: SocialRoutes

      # pages anyone can view
      scope "/", Bonfire.UI.Reflow do
        pipe_through :browser
        live "/resource/:id", ResourceLive
      end

    end
  end
end
