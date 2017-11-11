module Header exposing (header)

import Html exposing (..)
import Html.Attributes exposing (..)
import Game


header : Game.Model -> Html msg
header model =
    let
        headerText =
            case model.scene of
                Game.Playing ->
                    "Time: " ++ toString time |> text

                Game.Title ->
                    text "Press SPASE Key"

                Game.Dead ->
                    text "Press SPASE Key"
    in
        div [ class "Header" ] [ headerText ]
