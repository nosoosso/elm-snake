module Board exposing (board)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Game

board : Game.Board -> Html ()
board board = 
  boardHtml board

boardHtml : Game.Board -> Html ()
boardHtml board =
  let 
    row = 
      board
        |> Array.map boardRowHtml
        |> Array.toList
  in
    table [class "board"] 
      [ tbody [] row
      ]

boardRowHtml : Game.BoardRow -> Html ()
boardRowHtml row =
   row 
    |> Array.map boardItemHtml
    |> Array.toList
    |> tr [class "board-row"]

boardItemHtml : Game.BoardItem -> Html ()
boardItemHtml item =
  case item of
    Game.Snake life ->
      td [class "board-item board-item--snake"] [toString life |> text]
    Game.Item ->
      td [class "board-item board-item--item"] [text ""]
    Game.None ->
      td [class "board-item board-item--none"] [text ""]
