module Ions.Color.Extra exposing (colorToHex, hexToColor)

import Color
import Color.Convert
import Element


toColor : Element.Color -> Color.Color
toColor =
    Element.toRgb >> (\c -> Color.rgba c.red c.green c.blue c.alpha)


fromColor : Color.Color -> Element.Color
fromColor =
    Color.toRgba >> (\c -> Element.rgba c.red c.green c.blue c.alpha)


colorToHex : Element.Color -> String
colorToHex =
    toColor >> Color.Convert.colorToHex


hexToColor : String -> Element.Color
hexToColor =
    Color.Convert.hexToColor >> Result.withDefault (Color.rgb 0 0 0) >> fromColor
