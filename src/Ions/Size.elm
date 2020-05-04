module Ions.Size exposing (..)

import Element exposing (Attribute, fill, maximum, width)


base =
    16


proportion =
    0.95


proportionPx : Int -> Int
proportionPx n =
    round <| base * (proportion ^ toFloat n)


baseRem : Float -> Int
baseRem k =
    round <| k * base


measure : Attribute msg
measure =
    width <| maximum (30 * base) <| fill


measureWide : Attribute msg
measureWide =
    width <| maximum (34 * base) <| fill


measureNarrow : Attribute msg
measureNarrow =
    width <| maximum (20 * base) <| fill
