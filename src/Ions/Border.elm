module Ions.Border exposing (..)

import Element
import Element.Border exposing (color, roundEach, rounded, widthEach, widthXY, dotted)
import Ions.Color as TC
import Ions.Size as S


type Side
    = Left
    | Right
    | Top
    | Bottom
    | Sides
    | TopBottom
    | AllSides


type Corner
    = Lefts
    | Rights
    | Tops
    | Bottoms
    | LeftTop
    | RightTop
    | LeftBottom
    | RightBottom
    | Diagonal
    | CoDiagonal
    | AllCorners


width : Int -> Side -> Element.Attribute msg
width w s =
    case s of
        Left ->
            widthEach { bottom = 0, left = w, top = 0, right = 0 }

        Right ->
            widthEach { bottom = 0, left = 0, top = 0, right = w }

        Top ->
            widthEach { bottom = 0, left = 0, top = w, right = 0 }

        Bottom ->
            widthEach { bottom = w, left = 0, top = 0, right = 0 }

        Sides ->
            widthXY w 0

        TopBottom ->
            widthXY 0 w

        AllSides ->
            Element.Border.width w


radius : Int -> Corner -> Element.Attribute msg
radius w c =
    case c of
        Lefts ->
            roundEach { topLeft = w, topRight = 0, bottomLeft = w, bottomRight = 0 }

        Rights ->
            roundEach { topLeft = 0, topRight = w, bottomLeft = 0, bottomRight = w }

        Tops ->
            roundEach { topLeft = w, topRight = w, bottomLeft = 0, bottomRight = 0 }

        Bottoms ->
            roundEach { topLeft = 0, topRight = 0, bottomLeft = w, bottomRight = w }

        LeftTop ->
            roundEach { topLeft = w, topRight = 0, bottomLeft = 0, bottomRight = 0 }

        RightTop ->
            roundEach { topLeft = 0, topRight = w, bottomLeft = 0, bottomRight = 0 }

        LeftBottom ->
            roundEach { topLeft = 0, topRight = 0, bottomLeft = w, bottomRight = 0 }

        RightBottom ->
            roundEach { topLeft = 0, topRight = 0, bottomLeft = w, bottomRight = w }

        Diagonal ->
            roundEach { topLeft = w, topRight = 0, bottomLeft = 0, bottomRight = w }

        CoDiagonal ->
            roundEach { topLeft = 0, topRight = w, bottomLeft = w, bottomRight = 0 }

        AllCorners ->
            rounded w

width0 =
    width 0


width1 =
    width <| S.baseRem 0.125


width2 =
    width <| S.baseRem 0.25


width3 =
    width <| S.baseRem 0.5


width4 =
    width <| S.baseRem 1


width5 =
    width <| S.baseRem 2


radius0 =
    rounded 0


radius1 =
    rounded <| S.baseRem 0.125


radius2 =
    rounded <| S.baseRem 0.25


radius3 =
    rounded <| S.baseRem 0.5


radius4 =
    rounded <| S.base


pill =
    rounded 9999


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
