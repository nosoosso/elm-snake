import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Board
import Game

main =
  Html.beginnerProgram { model = model, view = view, update = update }

type alias Model = 
  { board : Game.Board
  }

model : Model
model =
  { board = Game.initBoard
  }

type alias Msg = ()

update : Msg -> Model -> Model
update msg model = 
  model

view : Model -> Html ()
view model =
  model.board
    |> Board.board 
