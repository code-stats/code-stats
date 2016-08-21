module Profile.TotalUpdater.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)

import Profile.Common.Types exposing (..)
import Profile.TotalUpdater.Types exposing (..)
import Profile.Common.ViewUtils exposing (..)

view : Model -> Html Msg
view model =
  div [] [
    h3 [] ([
      text "Level "
    ] ++ (progress_text model)),
    progress_bar model
  ]
