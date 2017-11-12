module MaybeUtils exposing (getOrCrash)


getOrCrash : String -> Maybe a -> a
getOrCrash error maybe =
    case maybe of
        Just a ->
            a

        Nothing ->
            Debug.crash error
