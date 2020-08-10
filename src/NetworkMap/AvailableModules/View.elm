module NetworkMap.AvailableModules.View exposing (..)

{-| Copyright 2020 Fluence Labs Limited

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

-}

import Element exposing (Element, alignRight, centerX, column, el, padding, row, text)
import Element.Input as Input
import Ions.Background as Background
import NetworkMap.AvailableModules.Model exposing (Model)
import NetworkMap.AvailableModules.Msg exposing (Msg(..))
import Palette exposing (fillWidth, limitLayoutWidth)
import Screen.Model as Screen


view : Screen.Model -> Model -> Element Msg
view screen model =
    let
        modulesEl =
            model.modules
                |> modulesView
    in
    column [ fillWidth ]
        modulesEl


modulesView : List String -> List (Element Msg)
modulesView modules =
    List.map moduleView modules


moduleView : String -> Element Msg
moduleView aModule =
    text aModule


optionsView : Model -> Element Msg
optionsView model =
    let
        btn =
            Input.button
                [ padding 10, Background.blackAlpha 60 ]
            <|
                { onPress = Just <| GetAvailableModules model.id
                , label =
                    Element.el
                        []
                        (Element.text "Get Available Modules")
                }
    in
    row [ limitLayoutWidth, Background.white, centerX ]
        [ el [ alignRight, padding 5 ] <| btn
        ]
