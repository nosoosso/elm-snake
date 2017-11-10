module Game exposing (Board, BoardRow, BoardActor(..), getActor, initBoard)

import Array exposing (Array)
import Const

type alias Board = Array BoardRow

type alias BoardRow = Array BoardActor

type BoardActor = Snake Int | Item | None

initBoard : Board 
initBoard = 
  let 
    board = 
      Array.repeat Const.boardSizeY (Array.repeat Const.boardSizeX None)
    boardWithSnake =  
      setActor (Const.boardSizeX // 3) (Const.boardSizeY // 2) (Snake 1) board
  in
    boardWithSnake

putItem : Board -> Board
putItem board =
  -- TODO
  board

getActor : Int -> Int -> Board -> BoardActor
getActor x y board = 
  case Array.get y board of
    Just row ->
      case Array.get x row of
        Just something ->
          something
        Nothing ->
          Debug.crash "invalid x index"
    Nothing ->
      Debug.crash "invalid y index"

setActor : Int -> Int -> BoardActor -> Board -> Board
setActor x y actor board =
  let
    currentBoardRow = 
      Array.get y board

    newBoardRow =
      case currentBoardRow of
        Just row ->
          Array.set x actor row
        Nothing ->
          Debug.crash "invalid x index"
  in
    Array.set y newBoardRow board

update : Board -> Board
update board =
  board