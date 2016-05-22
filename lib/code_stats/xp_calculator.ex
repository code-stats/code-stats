defmodule CodeStats.XPCalculator do
  @moduledoc """
  Calculations for levels based on XP.
  """

  @level_factor 0.05

  @doc """
  Get the level based on given XP.
  """
  @spec get_level(Integer.t) :: Integer.t
  def get_level(xp) do
    Float.floor(@level_factor * :math.sqrt(xp))
    |> trunc
  end

  @doc """
  Get the amount of XP required to reach the next level from the given level.
  """
  @spec get_next_level_xp(Integer.t) :: Integer.t
  def get_next_level_xp(level) do
    :math.pow(Float.ceil((level + 1) / @level_factor), 2)
    |> trunc
  end

  @doc """
  Get the progress to the next level in percentage.
  """
  @spec get_level_progress(Integer.t) :: Integer.t
  def get_level_progress(xp) do
    level = get_level(xp)
    current_level_xp = get_next_level_xp(level - 1)
    next_level_xp = get_next_level_xp(level)

    have_xp = xp - current_level_xp
    needed_xp = next_level_xp - current_level_xp
    Float.round((have_xp / needed_xp) * 100)
    |> trunc
  end
end
