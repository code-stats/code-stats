defmodule CodeStatsWeb.ViewUtils do
  @moduledoc """
  View functions and utilities common to most views.
  """

  @doc """
  Format amount of XP for display.
  """
  @spec format_xp(number) :: String.t
  def format_xp(xp) do
    Number.Delimit.number_to_delimited(xp, precision: 0)
  end
end
