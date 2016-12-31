defmodule CodeStats.ProfileView do
  use CodeStats.Web, :view

  # How many language XPs to display with progress bars
  @language_xp_amount 10

  def has_language_xps?(language_xps) do
    not Enum.empty?(language_xps)
  end

  def split_language_xps(language_xps) do
    Enum.split(language_xps, @language_xp_amount)
  end

  def has_more_language_xps?(language_xps) do
    Enum.count(language_xps) > @language_xp_amount
  end

  def has_machine_xps?(machine_xps) do
    not Enum.empty?(machine_xps)
  end

  def sort_xps(xps) do
    Enum.sort(xps, fn {_, a}, {_, b} -> a > b end)
  end
end
