module IndexPage.View exposing (view)

import IndexPage.Types exposing (..)

import Numeral exposing (format)
import Html exposing (..)
import Html.Attributes exposing (..)

-- How many languages to list in top total and current languages lists
max_top_langs = 10

format_number : Int -> String
format_number number =
  format "0,0" (toFloat number)

ticker_row : TickerDataRow -> Html Msg
ticker_row data =
  li [] [
    strong [] [
      text data.username
    ],
    text " +",
    text (format_number data.xp),
    text " ",
    text data.language
  ]

view : Model -> Html Msg
view model =
  let
    sorted_langs = List.sortBy .xp model.languages |> List.reverse |> List.take max_top_langs
    sorted_current_langs =
      List.sortBy .new_xp model.languages
      |> List.reverse
      |> List.filter (\l -> l.new_xp > 0)
      |> List.take max_top_langs
  in
    div [ class "col-xs-12" ] [
      div [ class "row" ] [
        div [ class "col-xs-12 col-sm-6" ] [
          h3 [] [
            text "Total XP"
          ],

          h2 [] [
            text (format_number model.total.xp),
            text " ",

            sup [] [
              text "(+",
              text (format_number model.total.new_xp),
              text ")"
            ]
          ]
        ],

        div [ class "col-xs-12 col-sm-6" ] [
          h3 [] [
            text "Total languages"
          ],

          h2 [] [
            text ((List.length model.languages) |> format_number)
          ]
        ]
      ],

      div [ class "row" ] [
        div [ class "col-xs-12 col-sm-6" ] [
          h3 [] [
            text "Top languages"
          ],

          ol [] (List.map (\l -> li [] [ text (l.name ++ ": " ++ (format_number l.xp) ++ " XP") ]) sorted_langs)
        ],

        div [ class "col-xs-12 col-sm-6" ] [
          h3 [] [
            text "Currently active languages"
          ],

          ol [] (List.map (\l -> li [] [ text (l.name ++ ": " ++ (format_number l.new_xp) ++ " XP") ]) sorted_current_langs)
        ]
      ],

      div [ class "row" ] [
        div [ class "col-xs-12" ] [ hr [] [] ]
      ],

      div [ class "row" ] [
        div [ class "col-xs-12" ] [
          ul [ class "ticker" ]
            (case model.tickerdata of
              [] -> [li [] [ text "Waiting for incoming XP…" ]]

              data -> (List.map ticker_row data))
        ]
      ]
    ]
