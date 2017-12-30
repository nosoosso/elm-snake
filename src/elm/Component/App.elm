module Component.App exposing (view)

import Html exposing (Html, button, div, text)
import Component.Board as Board
import Component.Footer as Footer
import Component.Header as Header
import Game


view : Game.Model -> Html msg
view model =
    Html.body []
        [ Header.header model
        , Board.board model.board
        , Footer.footer model
        ]
