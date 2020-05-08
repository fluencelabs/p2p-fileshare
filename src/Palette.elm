module Palette exposing (..)

import Element exposing (Element, el, mouseOver)
import Element.Background as Background
import Element.Border
import Element.Font as Font
import Element.Region as Region
import Html exposing (Html)
import Ions.Background as BG
import Ions.Border as B
import Ions.Color as C
import Ions.Font as F
import Ions.Size as S


accentFontColor =
    F.darkRed


letterSpacing =
    Font.letterSpacing 1.7


accentButton =
    [ F.white, BG.darkRed ]


blockBackground =
    BG.nearWhite


blockTitle inside =
    el [ fillWidth, accentFontColor, letterSpacing, Font.bold, Element.paddingXY 0 <| S.baseRem 1 ] <| inside


link : String -> String -> Element msg
link url label =
    Element.link
        linkStyle
        { url = url, label = Element.text label }


linkStyle =
    [ accentFontColor, C.easeIn, mouseOver [ BG.washedYellow ], Font.underline ]


h1 txt =
    el
        [ Region.heading 1
        , F.size2
        , Font.semiBold
        , Element.paddingXY 0 (S.baseRem 0.67)
        , F.code
        , accentFontColor
        ]
    <|
        Element.text txt


fillWidth =
    Element.width Element.fill


limitLayoutWidth =
    Element.width (Element.fill |> Element.maximum (S.baseRem 64))


layoutBlock =
    [ Element.centerX, limitLayoutWidth, Element.paddingXY (S.baseRem 4) (S.baseRem 1) ]


pSpacing =
    Element.spacing <| S.baseRem 0.5


shortHash hash =
    let
        sh =
            String.concat
                [ String.left 4 hash
                , "..."
                , String.right 3 hash
                ]
    in
    Element.el
        [ B.nearBlack
        , F.code
        ]
    <|
        Element.text sh


showHash hash =
    Element.el
        [ B.nearBlack
        , F.code
        ]
    <|
        Element.text hash


layout : List (Element msg) -> Html msg
layout elms =
    Element.layout
        [ F.size6
        , F.sansSerif
        , Element.padding (S.baseRem 1)
        ]
    <|
        Element.column
            [ Element.centerX
            , fillWidth
            ]
            elms
