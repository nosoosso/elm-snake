module Main exposing (..)

import Html exposing (Html, button, div, text)
import Board
import Game
import Header


main =
    Html.program
        { init = Game.init
        , view = view
        , update = Game.update
        , subscriptions = Game.subscriptions
        }


view : Game.Model -> Html msg
view model =
    Html.body []
        [ Header.header model
        , Board.board model.board
        ]
