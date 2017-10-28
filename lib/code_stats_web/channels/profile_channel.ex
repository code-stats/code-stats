defmodule CodeStatsWeb.ProfileChannel do
  use Phoenix.Channel

  alias CodeStats.User
  alias CodeStats.Pulse
  alias CodeStatsWeb.AuthUtils
  alias CodeStatsWeb.ProfileUtils

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
      true            <- !user.private_profile or socket.assigns[:user_id] === user.id,
      updated_cache   <- User.update_cached_xps(user),
      preloaded_cache <- ProfileUtils.preload_cache_data(updated_cache, user),
      processed_cache <- process_cache(user, preloaded_cache)
    do
      {:ok, processed_cache, socket}

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

    CodeStatsWeb.Endpoint.broadcast("users:#{user.username}", "new_pulse", %{xps: formatted_xps})
  end

  # Process cache to the correct format for the frontend and add recent XP data
  defp process_cache(user, cache) do
    now = DateTime.utc_now()
    latest_xp_since = Calendar.DateTime.subtract!(now, 3600 * ProfileUtils.recent_xp_hours)
    new_language_xps = ProfileUtils.get_language_xps_since(user, latest_xp_since)
    new_machine_xps = ProfileUtils.get_machine_xps_since(user, latest_xp_since)

    languages = cache.languages
    |> Enum.map(fn {%{id: id, name: name}, amount} ->
        new_xp = Map.get(new_language_xps, id, 0)

        %{
          name: name,
          xp: amount,
          new_xp: new_xp
        }
      end)

    machines = cache.machines
    |> Enum.map(fn {%{id: id, name: name}, amount} ->
        new_xp = Map.get(new_machine_xps, id, 0)

          %{
            name: name,
            xp: amount,
            new_xp: new_xp
          }
      end)

    %{
      total: %{
        xp: Enum.reduce(languages, 0, fn %{xp: amount}, acc -> acc + amount end),
        new_xp: Enum.reduce(languages, 0, fn %{new_xp: amount}, acc -> acc + amount end)
      },
      languages: languages,
      machines: machines
    }
  end
end
