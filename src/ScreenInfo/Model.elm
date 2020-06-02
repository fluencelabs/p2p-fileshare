module ScreenInfo.Model exposing (..)

import Element exposing (Device)

type alias Model =
    { device: Device
    }

phonePortrait : Model -> Bool
phonePortrait screenInfo =
    screenInfo.device.class == Element.Phone && screenInfo.device.orientation == Element.Portrait