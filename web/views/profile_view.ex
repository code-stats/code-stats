defmodule CodeStats.ProfileView do
  use CodeStats.Web, :view

  # How many language XPs to display with progress bars
  @language_xp_amount 10

  def get_xp_bar_widths(total_xp, new_xp) do
    level = get_level(total_xp)
    current_level_xp = get_next_level_xp(level - 1)

    have_xp = total_xp - current_level_xp

    if have_xp > new_xp do
      {
        get_level_progress(total_xp - new_xp),
        get_level_progress(total_xp) - get_level_progress(total_xp - new_xp)
      }
    else
      {
        0,
        get_level_progress(total_xp)
      }
    end
  end

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
end
