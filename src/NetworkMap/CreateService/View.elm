module NetworkMap.CreateService.View exposing (..)

import Element exposing (Element, alignRight, centerX, el, padding, row)
import Element.Input as Input
import Html
import Ions.Background as Background
import Multiselect
import NetworkMap.CreateService.Model exposing (Model)
import NetworkMap.CreateService.Msg exposing (Msg(..))
import Palette exposing (limitLayoutWidth)
import Screen.Model as Screen


optionsView : Screen.Model -> Model -> Element Msg
optionsView screen model =
    let
        multiselectView =
            Multiselect.view model.multiselect

        multiselectHtml =
            Html.map UpdateMultiSelect <| multiselectView

        multiselect =
            Element.html multiselectHtml

        btn =
            Input.button
                [ padding 10, Background.blackAlpha 60 ]
            <|
                { onPress = Just <| CreateService
                , label =
                    Element.el
                        []
                        (Element.text "Create Service")
                }
    in
    row [ limitLayoutWidth, Background.white, centerX ]
        [ el [ alignRight, padding 5 ] <| btn
        , multiselect
        ]
