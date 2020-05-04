module Ions.Color exposing (..)

import Element exposing (rgba255)
import Html.Attributes exposing (style)
import Ions.Color.Extra exposing (hexToColor)


easeIn =
    Element.htmlAttribute <| style "transition" "color .15s ease-in"


black =
    hexToColor "#000"


nearBlack =
    hexToColor "#111"


darkGray =
    hexToColor "#333"


midGray =
    hexToColor "#555"


gray =
    hexToColor "#777"


silver =
    hexToColor "#999"


lightSilver =
    hexToColor "#aaa"


moonGray =
    hexToColor "#ccc"


lightGray =
    hexToColor "#eee"


nearWhite =
    hexToColor "#f4f4f4"


white =
    hexToColor "#fff"


transparent =
    rgba255 0 0 0 0


blackAlpha k =
    rgba255 0 0 0 (k / 1000)


whiteAlpha k =
    rgba255 255 255 255 (k / 1000)


darkRed =
    hexToColor "#e7040f"


red =
    hexToColor "#ff4136"


lightRed =
    hexToColor "#ff725c"


orange =
    hexToColor "#ff6300"


gold =
    hexToColor "#ffb700"


yellow =
    hexToColor "#ffde37"


lightYellow =
    hexToColor "#fbf1a9"


purple =
    hexToColor "#5e2ca5"


lightPurple =
    hexToColor "#a463f2"


darkPink =
    hexToColor "#d5008f"


hotPink =
    hexToColor "#ff41b4"


pink =
    hexToColor "#ff80cc"


lightPink =
    hexToColor "#ffa3d7"


darkGreen =
    hexToColor "#137752"


green =
    hexToColor "#19a974"


lightGreen =
    hexToColor "#9eebcf"


navy =
    hexToColor "#001b44"


darkBlue =
    hexToColor "#00449e"


blue =
    hexToColor "#357edd"


lightBlue =
    hexToColor "#96ccff"


lightestBlue =
    hexToColor "#cdecff"


washedBlue =
    hexToColor "#f6fffe"


washedGreen =
    hexToColor "#e8fdf5"


washedYellow =
    hexToColor "#fffceb"


washedRed =
    hexToColor "#ffdfdf"
