module Game exposing (Board, BoardRow, BoardItem(..), get, initBoard)

import Array exposing (Array)
import Const

type alias Board = Array BoardRow

type alias BoardRow = Array BoardItem

type BoardItem = Snake Int | Item | None

initBoard : Board 
initBoard = 
  Array.repeat Const.boardSizeY (Array.repeat Const.boardSizeX None)

putItem : Board -> Board
putItem board =
  -- TODO
  board

get : Board -> Int -> Int -> BoardItem
get board x y = 
  case Array.get y board of
    Just row ->
      case Array.get x row of
        Just something ->
          something
        Nothing ->
          Debug.crash "invalid x index"
    Nothing ->
      Debug.crash "invalid y index"
