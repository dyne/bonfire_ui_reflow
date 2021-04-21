defmodule Bonfire.UI.Reflow.Routes do
  defmacro __using__(_) do

    quote do

      alias Bonfire.UI.Reflow.Routes.Helpers, as: SocialRoutes


      pipeline :bread_pub do
        plug :put_root_layout, {Bonfire.UI.Reflow.LayoutView, :root}
      end


      # pages anyone can view
      scope "/bread", Bonfire.UI.Reflow do
        pipe_through :browser

      end

      # pages you need an account to view
      scope "/bread", Bonfire.UI.Reflow do
        pipe_through :browser
        pipe_through :account_required

      end

      # VF pages you need to view as a user
      scope "/bread", Bonfire.UI.Reflow do
        pipe_through :browser
        pipe_through :user_required
        pipe_through :bread_pub

        live "/", BreadDashboardLive
        live "/milestones", ProcessesLive
        live "/milestone/:milestone_id", ProcessLive
        live "/intent/:intent_id", ProposalLive
        live "/proposal/:proposal_id", ProposalLive
        live "/proposed_intent/:proposed_intent_id", ProposalLive

        live "/map/", MapLive
        live "/map/:id", MapLive

      end
    end
  end
end
