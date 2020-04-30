module Palette exposing (..)

import Element exposing (Element, el, rgb255)
import Element.Background as Background
import Element.Font as Font
import Element.Region as Region
import Html exposing (Html)


linkColor =
    Font.color <| rgb255 107 107 212


buttonColor =
    Background.color <| rgb255 163 184 236


link : String -> String -> Element msg
link url label =
    Element.link
        [ linkColor ]
        { url = url, label = Element.text label }


h1 txt =
    el [ Region.heading 1, Font.size 18 ] <| Element.text txt


fillWidth =
    Element.width Element.fill


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
    Element.el [] <| Element.text sh


layout : List (Element msg) -> Html msg
layout elms =
    Element.layout [] <|
        Element.column
            [ Element.centerX
            , Element.width (Element.fill |> Element.maximum 680)
            , Font.size 16
            , Element.padding 20
            , Element.spacing 20
            ]
            elms
