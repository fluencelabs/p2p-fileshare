module NetworkMap.Services.View exposing (..)

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
import Html
import Ions.Background as Background
import Multiselect
import NetworkMap.Services.Model exposing (Model)
import NetworkMap.Services.Msg exposing (Msg(..))
import Palette exposing (fillWidth, limitLayoutWidth)
import Screen.Model as Screen


view : Screen.Model -> Model -> Element Msg
view screen model =
    row [ limitLayoutWidth, Background.white, centerX ]
        [ availableModulesView screen model, uploaderView screen model ]


availableModulesView : Screen.Model -> Model -> Element Msg
availableModulesView screen model =
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


optionsView : Screen.Model -> Model -> Element Msg
optionsView screen model =
    row [ limitLayoutWidth, Background.white, centerX ]
        [ optionsAvailableModulesView model, optionsCreateServiceView screen model, optionsUploaderView model ]


optionsAvailableModulesView : Model -> Element Msg
optionsAvailableModulesView model =
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
    el [ alignRight, padding 5 ] <| btn


optionsCreateServiceView : Screen.Model -> Model -> Element Msg
optionsCreateServiceView screen model =
    let
        multiselectView =
            Multiselect.view model.modulesMultiselect

        multiselectHtml =
            Html.map UpdateModulesMultiSelect <| multiselectView

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


uploaderView : Screen.Model -> Model -> Element Msg
uploaderView screen wasmUploader =
    case wasmUploader.resultName of
        Just rn ->
            text (rn ++ " is uploaded")

        Nothing ->
            Element.none


optionsUploaderView : Model -> Element Msg
optionsUploaderView model =
    let
        btn =
            Input.button
                [ padding 10, Background.blackAlpha 60 ]
            <|
                { onPress = Just <| UploadWasm
                , label =
                    Element.el
                        []
                        (Element.text "Upload Wasm")
                }

        nameInput =
            Input.text [ centerX, fillWidth ]
                { onChange = ChangeName
                , text = model.moduleName
                , placeholder = Just <| Input.placeholder [] <| text "Enter WASM module name"
                , label = Input.labelHidden "Enter WASM module name"
                }
    in
    row [ limitLayoutWidth, Background.white, centerX ]
        [ el [ alignRight, padding 5 ] <| btn
        , el [ alignRight, padding 5 ] <| nameInput
        ]
