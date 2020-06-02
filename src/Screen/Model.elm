module Screen.Model exposing (..)

import Element exposing (Device)

type alias Model =
    { device: Device
    , proportions: { width: Int, height: Int }
    }

isMedium : Model -> Bool
isMedium screen =
    screen.proportions.width < 860

isNarrow : Model -> Bool
isNarrow screen =
    screen.proportions.width < 500
