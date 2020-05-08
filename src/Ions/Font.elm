module Ions.Font exposing (..)

import Element.Font exposing (color, size)
import Ions.Color as TC
import Ions.Size as S


sansSerif =
    Element.Font.family <| List.map Element.Font.typeface [ "-apple-system", "BlinkMacSystemFont", "avenir next", "avenir", "helvetica neue", "helvetica", "ubuntu", "roboto", "noto", "segoe ui", "arial", "sans-serif" ]


code =
    Element.Font.family <| List.map Element.Font.typeface [ "Consolas", "monaco", "monospace" ]


baseSize =
    size S.base


size1 =
    size <| S.baseRem 3


size2 =
    size <| S.baseRem 2.25


size3 =
    size <| S.baseRem 1.5


size4 =
    size <| S.baseRem 1.25


size5 =
    size <| S.baseRem 1


size6 =
    size <| S.baseRem 0.875


size7 =
    size <| S.baseRem 0.75


black =
    color TC.black


nearBlack =
    color TC.nearBlack


darkGray =
    color TC.darkGray


midGray =
    color TC.midGray


gray =
    color TC.gray


silver =
    color TC.silver


lightSilver =
    color TC.lightSilver


moonGray =
    color TC.moonGray


lightGray =
    color TC.lightGray


nearWhite =
    color TC.nearWhite


white =
    color TC.white


transparent =
    color TC.transparent


blackAlpha k =
    color <| TC.blackAlpha k


whiteAlpha k =
    color <| TC.whiteAlpha k


darkRed =
    color TC.darkRed


red =
    color TC.red


lightRed =
    color TC.lightRed


orange =
    color TC.orange


gold =
    color TC.gold


yellow =
    color TC.yellow


lightYellow =
    color TC.lightYellow


purple =
    color TC.purple


lightPurple =
    color TC.lightPurple


darkPink =
    color TC.darkPink


hotPink =
    color TC.hotPink


pink =
    color TC.pink


lightPink =
    color TC.lightPink


darkGreen =
    color TC.darkGreen


green =
    color TC.green


lightGreen =
    color TC.lightGreen


navy =
    color TC.navy


darkBlue =
    color TC.darkBlue


blue =
    color TC.blue


lightBlue =
    color TC.lightBlue


lightestBlue =
    color TC.lightestBlue


washedBlue =
    color TC.washedBlue


washedGreen =
    color TC.washedGreen


washedYellow =
    color TC.washedYellow


washedRed =
    color TC.washedRed
