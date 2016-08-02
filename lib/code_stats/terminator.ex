defmodule CodeStats.Terminator do
  @moduledoc """
  The Terminator is a timed assassin designed to delete unneeded, invalid data
  from the system.
  """

  import Ecto.Query, only: [from: 2]

  alias Calendar.DateTime, as: CDateTime

  alias CodeStats.{
    Repo,
    PasswordReset
  }

  # List of targets to assassinate. Should contain 2-tuples where the first element
  # is the function to call and the second is how often to call it, in milliseconds.
  # Functions to call must have 0 arity.
  @targets [
    {:clear_old_password_reset_tokens, 24 * 60 * 60 * 1000}
  ]

  def start_link() do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    start_timers()

    {:ok, state}
  end

  @doc """
  Start the timers that will execute the targets.
  """
  def start_timers() do
    Enum.each(@targets, fn {fun, time} ->
      Process.send_after(self(), {fun, time}, time)
    end)
  end

  def handle_info({fun, time}, state) do
    apply(__MODULE__, fun, [])
    Process.send_after(self(), {fun, time}, time)

    {:noreply, state}
  end

  def clear_old_password_reset_tokens() do
    now = DateTime.utc_now()
    earliest_valid = CDateTime.subtract!(now, PasswordReset.token_max_life() * 3600)

    (from pr in PasswordReset,
      where: pr.inserted_at < ^earliest_valid)

    |> Repo.delete_all()
  end
end
