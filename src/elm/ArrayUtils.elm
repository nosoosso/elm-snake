module ArrayUtils exposing (getOrCrash)

import Array exposing (Array)


getOrCrash : String -> Int -> Array a -> a
getOrCrash error index array =
    case Array.get index array of
        Just item ->
            item

        Nothing ->
            Debug.crash error
