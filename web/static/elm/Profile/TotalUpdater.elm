module Profile.TotalUpdater exposing (..)

import Html.App as Html

import Profile.Common.Types exposing (..)
import Profile.TotalUpdater.View exposing (view)
import Profile.TotalUpdater.Types exposing (..)
import Profile.TotalUpdater.Ports exposing (..)

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

init : (Model, Cmd Msg)
init =
  ({xp = 0, new_xp = 0}, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Init data ->
      ({ xp = data.total.xp, new_xp = data.total.new_xp }, Cmd.none)

    NewXP data ->
      (handle_new_data model data, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ tu_initialize Init
    , tu_new_xp NewXP
    ]

handle_new_data : Model -> XPData -> Model
handle_new_data model data =
  List.foldl handle_data_row model data.xps

handle_data_row : XPDataRow -> Model -> Model
handle_data_row row {xp, new_xp} =
  { xp = xp + row.amount
  , new_xp = new_xp + row.amount
  }
