module Main exposing (..)

import Html exposing (Html, button, div, text)
import Time exposing (Time, millisecond)
import Board
import Const
import Game
import Header

main =
  Html.program
   { init = init
   , view = view
   , update = update 
   , subscriptions = subscriptions
   }

type alias Model = 
  { board : Game.Board
  , time: Int
  }

initModel : Model
initModel =
  { board = Game.initBoard
  , time = 0
  }

init : (Model, Cmd Msg)
init =
  (initModel, Cmd.none)

type Msg = Tick Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  case msg of
    Tick newTime ->
      let
        newModel = {model | time = model.time + 1}
      in
        (newModel, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every (Const.gameSpeed * millisecond) Tick

view : Model -> Html msg
view model =
  Html.body [] 
    [ Header.header model.time
    , Board.board model.board
    ]

