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


linkColor =
    F.darkBlue


buttonColor =
    BG.orange


link : String -> String -> Element msg
link url label =
    Element.link
        [ linkColor, C.easeIn, mouseOver [ BG.washedYellow ] ]
        { url = url, label = Element.text label }


h1 txt =
    el [ Region.heading 1, F.size1, Font.semiBold, Element.centerX ] <| Element.text txt


fillWidth =
    Element.width Element.fill


limitLayoutWidth =
    Element.width (Element.fill |> Element.maximum 700)


dropdownBg =
    Background.color <| Element.rgb255 210 187 187


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
        , Font.family [ Font.monospace ]
        ]
    <|
        Element.text sh


layout : List (Element msg) -> Html msg
layout elms =
    Element.layout [] <|
        Element.column
            [ Element.centerX
            , fillWidth
            , F.baseSize
            ]
            elms
