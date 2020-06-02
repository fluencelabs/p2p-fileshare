module Screen.Model exposing (..)

import Element exposing (Device)

type alias Model =
    { device: Device
    , proportions: { width: Int, height: Int }
    }

isMedium : Model -> Bool
isMedium screen =
    (screen.device.class == Element.Phone || screen.device.class == Element.Tablet) && screen.device.orientation == Element.Portrait

isNarrow : Model -> Bool
isNarrow screen =
    screen.device.class == Element.Phone && screen.device.orientation == Element.Portrait
