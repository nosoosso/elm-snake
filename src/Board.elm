import Html exposing (..)

type alias Model =
  { a : Int
  }

type Msg = Hello

board : Model -> Html Msg
board = 
  div [onClick Hello] [text "hello"]