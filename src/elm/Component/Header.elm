module Component.Header exposing (header)

import Html exposing (..)
import Html.Attributes exposing (..)
import Game


header : Game.Model -> Html msg
header model =
    let
        timeText =
            "Time: " ++ toString model.time |> text

        scoreText =
            "Score: " ++ toString model.score |> text
    in
        div [ class "Header" ]
            [ div [ class "Header__item" ] [ timeText ]
            , div [ class "Header__item" ] [ scoreText ]
            ]
