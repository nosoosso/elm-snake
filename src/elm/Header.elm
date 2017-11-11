module Header exposing (header)

import Html exposing (..)
import Html.Attributes exposing (..)


header : Int -> Html msg
header time =
    div [ class "Header" ] [ "Time: " ++ toString time |> text ]
