module Profile.Common.ViewUtils exposing (..)

import Profile.Common.Types exposing (..)
import Profile.Common.XPUtils exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)

{-|
  Return the new XP part of the progress text, if there is new XP.
-}
new_xp_sup : Progress -> List (Html Msg)
new_xp_sup progress =
  if progress.new_xp > 0 then
    [
      sup [] [
        text " (+",
        span [ class "recent-xp-amount" ] [
          text (format_xp progress.new_xp)
        ],
        text ")"
      ]
    ]
  else
    []

{-|
  Return the text of the progress, starting from the level ("15 (100,000 XP)…").
-}
progress_text : Progress -> List (Html Msg)
progress_text progress =
  [
    span [ class "xp-level" ] [
      text (progress.xp |> get_level |> toString)
    ],
    text " (",
    span [ class "x-amount" ] [
      text ((format_xp progress.xp) ++ " XP")
    ],
    text ")"
  ] ++ (new_xp_sup progress)

{-|
  Return the text of the progress for a named progress ("X level 15…").
-}
named_progress_text : NamedProgress -> List (Html Msg)
named_progress_text progress =
  [
    strong [] [
      text progress.name
    ],
    text " level "
  ] ++ (progress_text {xp = progress.xp, new_xp = progress.new_xp})

{-|
  Return a progress bar for the given progress.
-}
progress_bar : Progress -> Html Msg
progress_bar progress =
  let
    (old_width, new_width) = get_bar_widths progress.xp progress.new_xp
  in
    div [ class "progress" ] [
      div [
        class "progress-bar progress-bar-success",
        attribute "role" "progressbar",
        style [("width", (toString old_width) ++ "%")]
      ] [
        span [ class "sr-only" ] [
          text ("Level progress " ++ (toString old_width) ++ "%.")
        ]
      ],
      div [
        class "progress-bar progress-bar-striped progress-bar-warning",
        attribute "role" "progressbar",
        style [("width", (toString new_width) ++ "%")]
      ] [
        span [ class "sr-only" ] [
          text ("Recent level progress " ++ (toString new_width) ++ "%.")
        ]
      ]
    ]

{-|
  Return a language progress with progress bar and title.
-}
language_progress_bar_view : NamedProgress -> Html Msg
language_progress_bar_view progress =
  div [] [
    h4 [] (named_progress_text progress),
    progress_bar {xp = progress.xp, new_xp = progress.new_xp}
  ]

{-|
  Return a language progress list element (for "more languages" list).
-}
language_list_view : NamedProgress -> Html Msg
language_list_view progress =
  li [ class "profile-more-language-progress" ] (named_progress_text progress)

{-|
  Return a machine progress list element with progress bar.
-}
machine_progress_bar_view : NamedProgress -> Html Msg
machine_progress_bar_view progress =
  li [
    class "profile-machine-progress"
  ] ((named_progress_text progress) ++ [progress_bar {xp = progress.xp, new_xp = progress.new_xp}])
