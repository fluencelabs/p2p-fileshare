module ScreenInfo.Model exposing (..)

import Element exposing (Device)

type alias Model =
    { device: Device
    , proportions: { width: Int, height: Int }
    }

isMedium : Model -> Bool
isMedium screenInfo =
    (screenInfo.device.class == Element.Phone || screenInfo.device.class == Element.Tablet) && screenInfo.device.orientation == Element.Portrait

isNarrow : Model -> Bool
isNarrow screenInfo =
    screenInfo.device.class == Element.Phone && screenInfo.device.orientation == Element.Portrait