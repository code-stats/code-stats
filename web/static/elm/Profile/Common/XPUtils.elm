module Profile.Common.XPUtils exposing (..)

import Numeral exposing (format)

level_factor = 0.025

{-|
  Get level based on XP.
-}
get_level : Int -> Int
get_level xp =
  toFloat xp
    |> sqrt
    |> ((*) level_factor)
    |> floor

{-|
  Get the amount of XP required to reach the next level from the given level.
-}
get_next_level_xp : Int -> Int
get_next_level_xp level =
  level + 1
    |> toFloat
    |> (\n -> n / level_factor)
    |> ceiling
    |> (\n -> n^2)

{-|
  Get the progress to the next level in percentage.
-}
get_level_progress : Int -> Int
get_level_progress xp =
  let
    level = get_level xp
    current_level_xp = get_next_level_xp(level - 1)
    next_level_xp = get_next_level_xp level
    have_xp = toFloat(xp - current_level_xp)
    needed_xp = toFloat(next_level_xp - current_level_xp)
  in
    have_xp / needed_xp
      |> (\n -> n * 100)
      |> round

get_bar_widths : Int -> Int -> (Int, Int)
get_bar_widths xp new_xp =
  let
    level = get_level xp
    current_level_xp = get_next_level_xp(level - 1)
    have_xp = xp - current_level_xp

  in
    if have_xp > new_xp then
      (
        get_level_progress(xp - new_xp),
        get_level_progress(xp) - get_level_progress(xp - new_xp)
      )
    else
      (
        0,
        get_level_progress(xp)
      )

format_xp : Int -> String
format_xp xp =
  format "0,0" (toFloat xp)
