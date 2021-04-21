defmodule Bonfire.UI.Reflow.ProposalLive do
  use Bonfire.Web, {:live_view, [layout: {Bonfire.UI.Reflow.LayoutView, "live.html"}]}

  use AbsintheClient, schema: Bonfire.GraphQL.Schema, action: [mode: :internal]

  alias Bonfire.Web.LivePlugs
  alias Bonfire.Me.Users
  alias Bonfire.UI.Social.{ParticipantsLive}
  alias Bonfire.Me.Web.{CreateUserLive, LoggedDashboardLive}

  def mount(params, session, socket) do
    LivePlugs.live_plug params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      LivePlugs.StaticChanged,
      LivePlugs.Csrf,
      &mounted/3,
    ]
  end

  defp mounted(%{"intent_id"=> intent_id}, session, socket) do

    intent = intent_by_id(intent_id, socket)
    IO.inspect(intent)

    {:ok, socket
    |> assign(page_title: "Intent",
    selected_tab: "about",
    intent: intent,
    main_labels: []
    )}
  end

  defp mounted(params, session, socket) do

    {:ok, socket
    |> assign(page_title: "Proposal",
    selected_tab: "about",
    intent: nil
    )}
  end

  @graphql """
    query($id: ID) {
      intent(id: $id) {
        id
        name
        provider
        receiver
        at_location

      }
    }
  """
  def intent(params, socket), do: []
  def intent_by_id(id, socket), do: intent(%{id: id}, socket)


end
