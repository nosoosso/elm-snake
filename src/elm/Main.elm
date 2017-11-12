module Main exposing (..)

import Html exposing (Html, button, div, text)

import Component.App as App
import Game


main =
    Html.program
        { init = Game.init
        , view = App.view
        , update = Game.update
        , subscriptions = Game.subscriptions
        }
