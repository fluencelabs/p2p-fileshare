module Screen.Model exposing (..)

import Element exposing (Device)

type alias Model =
    { device: Device
    , screenSize: { width: Int, height: Int }
    }

isMedium : Model -> Bool
isMedium screen =
    screen.screenSize.width < 860

isNarrow : Model -> Bool
isNarrow screen =
    screen.screenSize.width < 500
