module Board exposing (board)

import Array exposing (Array)
import Html exposing (..)
import Game

board : Game.Board -> Html ()
board board = 
  boardHtml board

boardHtml : Game.Board -> Html ()
boardHtml board =
  board
    |> Array.map boardRowHtml
    |> Array.toList
    |> table []

boardRowHtml : Game.BoardRow -> Html ()
boardRowHtml row =
   row 
    |> Array.map boardItemHtml
    |> Array.toList
    |> tr []

boardItemHtml : Game.BoardItem -> Html ()
boardItemHtml item =
  case item of
    Game.Snake life ->
      td [] [toString life |> text]
    Game.Item ->
      td [] [text "@"]
    Game.None ->
      td [] [text "_"]
