defmodule CodeStats.ProfileChannel do
  use Phoenix.Channel

  alias CodeStats.{
    User,
    AuthUtils,
    Pulse
  }

  @moduledoc """
  The profile channel is used to broadcast information about a certain user's
  profile when it is updated.
  """

  def join("users:" <> username, _params, socket) do
    # Profile channel can be accessed if:
    # The profile is public, OR
    # the current user is the same as the profile user.

    with \
      %User{} = user  <- AuthUtils.get_user(username),
      true            <- !user.private_profile or socket.assigns[:user_id] === user.id
    do
      {:ok, socket}

    else
      _ -> {:error, %{reason: "Unauthorized."}}
    end
  end

#  def handle_out("new_pulse", payload, socket) do
#    push(socket, "new_pulse", payload)
#    {:noreply, socket}
#  end

  @doc """
  API to send new pulse to channel.

  Chooses the correct user channel based on the user. The given pulse must have
  xps and machine preloaded, xps themselves must have language preloaded.
  """
  def send_pulse(%User{} = user, %Pulse{xps: xps, machine: machine})
      when not is_nil(xps) and not is_nil(machine) do

    formatted_xps = for xp <- xps do
      %{
        amount: xp.amount,
        machine: machine.name,
        language: xp.language.name
      }
    end

    CodeStats.Endpoint.broadcast("users:#{user.username}", "new_pulse", %{xps: formatted_xps})
  end
end
