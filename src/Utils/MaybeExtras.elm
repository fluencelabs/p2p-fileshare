module Utils.MaybeExtras exposing (..)


isEmpty : Maybe a -> Bool
isEmpty maybe =
    case maybe of
        Just _ ->
            False

        Nothing ->
            True


nonEmpty : Maybe a -> Bool
nonEmpty m =
    not <| isEmpty m
