module NetworkMap.Interfaces.View exposing (..)

import Element exposing (Element, column, width)
import Element.Font as Font
import Element.Input as Input
import NetworkMap.Interfaces.Msg exposing (Msg(..))
import NetworkMap.Interfaces.Model exposing (Model)
import Palette exposing (fillWidth)
import Screen.Model as Screen

view : Screen.Model -> Model -> Element Msg
view screen model =
    let
        _ = Debug.log "" "call"
    in
    column [ fillWidth ]
        [Input.button
                 [ width <| Element.px 80 ]
             <|
                 { onPress = Just <| GetInterface ""
                 , label =
                     Element.el
                         [ Font.underline
                         ]
                         (Element.text "Get Interfaces")
                 }]
