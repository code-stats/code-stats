module Profile.TotalUpdater.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)

import Profile.Common.Types exposing (..)
import Profile.TotalUpdater.Types exposing (..)
import Profile.Common.ViewUtils exposing (..)

view : Model -> Html Msg
view model =
  case (model.xp, model.new_xp) of
    (0, 0) ->
      div [] [
        h3 [] [
          text "Loading live update data…"
        ]
      ]

    _ ->
      div [] [
        h3 [] ([
          text "Level "
        ] ++ (progress_text model)),
        progress_bar model
      ]
