module Screen.Subscriptions exposing (..)

import Browser.Events exposing (onResize)
import Element
import Screen.Msg exposing (Msg(..))


subscriptions =
    onResize <|
        \width height ->
            WindowResized (Element.classifyDevice { width = width, height = height }) width height
