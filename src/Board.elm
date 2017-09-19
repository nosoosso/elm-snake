module Board exposing (board)

import Array exposing (Array)
import Html exposing (..)
import Game

board : Game.Board -> Html ()
board board = 
  table [] [genBoardHtml board]

genBoardHtml : Game.Board -> Html ()
genBoardHtml board =
  let
   boardTr = 
     board
      |> Array.map genRow
      |> Array.toList
  in
    table [] boardTr

genRow : Game.BoardRow -> Html ()
genRow row =
   row 
    |> Array.map boardRowHtml
    |> Array.toList
    |> tr []

boardRowHtml : Game.BoardItem -> Html ()
boardRowHtml item =
  case item of
    Game.Snake life ->
      td [] [toString life |> text]
    Game.Item ->
      td [] [text "@"]
    Game.None ->
      td [] [text "_"]
