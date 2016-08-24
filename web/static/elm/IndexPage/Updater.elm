module IndexPage.Updater exposing (..)

import Html.App as Html

import IndexPage.Types exposing (..)
import IndexPage.View exposing (view)
import IndexPage.Ports exposing (..)

-- Maximum number of rows to show in ticker
ticker_max_rows = 5

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

init : (Model, Cmd Msg)
init =
  ({ total = { xp = 0, new_xp = 0}
   , languages = []
   , tickerdata = []
   }, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Init data ->
      ({ total = { xp = data.total_xp, new_xp = 0 }
       , languages = List.map (\l -> { xp = l.xp, name = l.name, new_xp = 0 }) data.languages
       , tickerdata = []
       }, Cmd.none)

    NewXP data ->
      (handle_new_data model data, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ iu_initialize Init
    , iu_new_xp NewXP
    ]

handle_new_data : Model -> TickerDataRow -> Model
handle_new_data model data =
  { total = { xp = model.total.xp + data.xp, new_xp = model.total.new_xp + data.xp }
  , languages = update_language_list model.languages { xp = data.xp, language = data.language }
  , tickerdata = update_ticker_data model.tickerdata data
  }

update_language_list : List Language -> {xp : Int, language : String} -> List Language
update_language_list list {xp, language} =
  let
    (match, rest) = List.partition (\n -> n.name == language) list
  in
    match
    |> List.head
    |> (Maybe.withDefault {xp = 0, new_xp = 0, name = language})
    |> (update_language xp)
    |> (\l -> l :: rest)

update_language : Int -> Language -> Language
update_language xp language =
  { language |
      xp = language.xp + xp,
      new_xp = language.new_xp + xp
  }

update_ticker_data : List TickerDataRow -> TickerDataRow -> List TickerDataRow
update_ticker_data list data =
  list
    |> List.reverse
    |> List.drop ((List.length list) |> (\n -> (n + 1) - ticker_max_rows) |> max(0))
    |> List.reverse
    |> ((::) data)
