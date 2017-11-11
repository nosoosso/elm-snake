module Board exposing (board)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Game


board : Game.Board -> Html msg
board board =
    boardHtml board


boardHtml : Game.Board -> Html msg
boardHtml board =
    let
        row =
            board
                |> Array.map boardRowHtml
                |> Array.toList
    in
        table [ class "board" ]
            [ tbody [] row
            ]


boardRowHtml : Game.BoardRow -> Html msg
boardRowHtml row =
    row
        |> Array.map boardActorHtml
        |> Array.toList
        |> tr [ class "board-row" ]


boardActorHtml : Game.BoardActor -> Html msg
boardActorHtml item =
    case item of
        Game.Snake life ->
            td [ class "board-item board-item--snake" ] [ toString life |> text ]

        Game.Item ->
            td [ class "board-item board-item--item" ] [ text "" ]

        Game.None ->
            td [ class "board-item board-item--none" ] [ text "" ]
