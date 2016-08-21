module Profile.MainUpdater exposing (..)

import Html.App as Html

import Profile.Common.Types exposing (..)
import Profile.MainUpdater.View exposing (view)
import Profile.MainUpdater.Types exposing (..)
import Profile.MainUpdater.Ports exposing (..)

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

init : (Model, Cmd Msg)
init =
  ({languages = [], machines = []}, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Init data ->
      ({languages = data.languages, machines = data.machines}, Cmd.none)

    NewXP data ->
      (handle_new_data model data, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ mu_initialize Init
    , mu_new_xp NewXP
    ]

handle_new_data : Model -> XPData -> Model
handle_new_data model data =
  List.foldl handle_data_row model data.xps

handle_data_row : XPDataRow -> Model -> Model
handle_data_row row {languages, machines} =
  { languages = update_progress_list languages {amount = row.amount, name = row.language}
  , machines = update_progress_list machines {amount = row.amount, name = row.machine}
  }

update_progress_list : List NamedProgress -> {amount : Int, name : String} -> List NamedProgress
update_progress_list list row =
  let
    (match, rest) = List.partition (\n -> n.name == row.name) list
  in
    match
    |> List.head
    |> (Maybe.withDefault {xp = 0, new_xp = 0, name = row.name})
    |> (update_named_progress row)
    |> (\n -> n :: rest)

update_named_progress : {amount : Int, name : String} -> NamedProgress -> NamedProgress
update_named_progress {amount, name} progress =
  { xp = progress.xp + amount
  , new_xp = progress.new_xp + amount
  , name = progress.name
  }
