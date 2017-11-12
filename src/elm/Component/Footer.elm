module Component.Footer exposing (footer)

import Html exposing (..)
import Html.Attributes exposing (..)
import Game


footer : Game.Model -> Html msg
footer model =
    let
        headerText =
            case model.scene of
                Game.Playing ->
                    "Time: " ++ toString model.playing.time |> text

                Game.Title ->
                    text "Press SPASE Key"

                Game.Dead ->
                    text "Press SPASE Key"
    in
        div [ class "Header" ] [ headerText ]
