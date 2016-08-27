module Profile.MainUpdater.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)

import Profile.Common.Types exposing (..)
import Profile.MainUpdater.Types exposing (..)
import Profile.Common.ViewUtils exposing (..)

language_limit = 10

language_row : NamedProgress -> Html Msg
language_row progress =
  div [] [language_progress_bar_view progress]

maybe_more_language_progress : List NamedProgress -> Html Msg
maybe_more_language_progress languages =
  if List.length languages > 0 then
    div [ class "col-xs-12 col-sm-6" ] [
      h4 [] [
        text "Other languages"
      ],

      ol [ start (language_limit + 1) ] (List.map language_list_view languages)
    ]
  else
    -- Fake an empty node
    text ""

view : Model -> Html Msg
view {languages, machines} =
  let
    sorted_langs = List.reverse (List.sortBy .xp languages)
    sorted_machines = List.reverse (List.sortBy .xp machines)
    langs = List.take language_limit sorted_langs
    more_langs = List.drop language_limit sorted_langs
  in
    div [] [
      div [ class "row" ] [
        div [ class "col-xs-12 language-progress" ] (List.map language_row langs)
      ],

      div [ class "row" ] [
        div [ class "col-xs-12" ] [
          hr [] [],
          p [ class "text-center" ] [
            small [] [
              text "XP gained recently is highlighted."
            ]
          ]
        ]
      ],

      div [ class "row" ] [
        div [ class "col-xs-12" ] [
          hr [] []
        ]
      ],

      div [ class "row" ] [
        maybe_more_language_progress more_langs,

        div [ class "col-xs-12 col-sm-6" ] [
          div [ class "row" ] [
            div [ class "col-xs-12" ] [
              h4 [] [ text "Machines" ],
              ol [] (List.map machine_progress_bar_view sorted_machines)
            ]
          ]
        ]
      ]
    ]
