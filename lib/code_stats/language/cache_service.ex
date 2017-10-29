defmodule CodeStats.Language.CacheService do
  @moduledoc """
  The cache service implements a simple key-value cache that stores its values in ETS
  (Erlang Term Storage) and optionally refreshes them periodically.

  It also manages ownership of the ETS tables of the cache. The tables are set to public so that
  outside processes (such as request handlers) can add values to the cache.
  """
  use GenServer

  import Ecto.Query, only: [from: 2]

  alias CodeStats.Repo
  alias CodeStats.Language
  alias CodeStats.XP

  # Table names
  @language_xp_cache_table :cache_service_language_xp_cache

  # Timers for refreshing data
  @total_language_xp_refresh_timer 900 * 1000

  def start_link() do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    :ets.new(@language_xp_cache_table, [:named_table, :set, :public, read_concurrency: true, write_concurrency: true])

    refresh_total_language_xp_and_repeat()

    {:ok, state}
  end





  @doc """
  Add the given amount of XP for the given language in the total language XP cache.

  Returns the new amount of XP for the language in the cache.
  """
  @spec add_total_language_xp(%Language{}, integer) :: integer
  def add_total_language_xp(language, value) do
    # Form key for possible future use
    key = {language.name, :total}

    case :ets.update_counter(@language_xp_cache_table, key, {2, value}, {key, value}) do
      new_count when is_integer(new_count) -> new_count
      _ -> raise "Updating counter #{inspect key} failed!"
    end
  end

  @doc """
  Get the total XP in the system for each language. Returns a list of tuples where the first
  element is the language name and the second element is the amount of XP.
  """
  @spec get_total_language_xps() :: [{String.t, integer}]
  def get_total_language_xps() do
    :ets.match_object(@language_xp_cache_table, {{:"$1", :total}, :"$2"})
    |> Enum.map(fn {{lang_name, :total}, amount} -> {lang_name, amount} end)
  end





  def handle_info(:refresh_total_language_xp, state) do
    refresh_total_language_xp_and_repeat()
    {:noreply, state}
  end

  defp refresh_total_language_xp_and_repeat() do
    refresh_total_language_xp()
    Process.send_after(self(), :refresh_total_language_xp, @total_language_xp_refresh_timer)
  end

  @doc """
  Refresh all data in total language XP cache.
  """
  @spec refresh_total_language_xp() :: true
  def refresh_total_language_xp() do
    # Remove old languages as aliases can otherwise result in duplicate items
    :ets.delete_all_objects(@language_xp_cache_table)

    most_popular_q = from x in XP,
      join: l in Language, on: l.id == x.language_id,
      group_by: l.id,
      order_by: [desc: sum(x.amount)],
      select: {l, sum(x.amount)}

    most_popular = case Repo.all(most_popular_q) do
      nil -> []
      ret -> ret
    end
    |> Enum.map(fn {lang, amount} -> {{lang.name, :total}, amount} end)

    :ets.insert(@language_xp_cache_table, most_popular)
  end
end
