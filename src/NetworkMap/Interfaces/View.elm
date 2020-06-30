module NetworkMap.Interfaces.View exposing (..)

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

import Array exposing (Array)
import Dict exposing (Dict)
import Element exposing (Element, alignRight, centerX, column, el, fillPortion, padding, paddingXY, row, spacing, text, width)
import Element.Font as Font
import Element.Input as Input
import Ions.Background as Background
import Ions.Font as F
import Ions.Size as S
import NetworkMap.Interfaces.Model exposing (Function, Inputs, Interface, Model, Module)
import NetworkMap.Interfaces.Msg exposing (Msg(..))
import Palette exposing (accentButton, fillWidth, letterSpacing, limitLayoutWidth)
import Screen.Model as Screen


view : Screen.Model -> Model -> Element Msg
view screen model =
    let
        modulesEl =
            (model.interface |> Maybe.map (interfaceForms model.id model.inputs)) |> Maybe.withDefault Element.none
    in
    column [ fillWidth ]
        [ modulesEl ]


optionsView : Model -> Element Msg
optionsView model =
    let
        btn =
            Input.button
                [ padding 10, Background.blackAlpha 60 ]
            <|
                { onPress = Just <| GetInterface model.id
                , label =
                    Element.el
                        []
                        (Element.text "Get Interfaces")
                }
    in
    row [ limitLayoutWidth, Background.white, centerX ]
        [ el [ alignRight, padding 5 ] <| btn
        ]


interfaceForms : String -> Inputs -> Interface -> Element Msg
interfaceForms id inputs interface =
    let
        modules =
            interface.modules
    in
    column [ fillWidth, spacing 10 ] (modules |> List.map (moduleForms id inputs))


defn : String -> Element Msg
defn t =
    el [ width (fillPortion 2), letterSpacing, F.gray ] <| Element.text t


valn : Element Msg -> Element Msg
valn t =
    el [ width (fillPortion 5), Font.size 16 ] <| t


moduleForms : String -> Inputs -> Module -> Element Msg
moduleForms id inputs mod =
    let
        name =
            mod.name

        nameEl =
            row [ fillWidth, centerX, padding 8 ] [ defn "Module: ", valn <| text name ]

        functions =
            mod.functions
    in
    column [ fillWidth, Background.blackAlpha 20, padding 10 ] ([ nameEl ] ++ (functions |> List.map (functionForms id inputs name)))


functionForms : String -> Inputs -> String -> Function -> Element Msg
functionForms id inputs moduleId function =
    let
        name =
            function.name

        nameEl =
            row [ fillWidth, centerX ] [ defn "Function: ", valn <| text name ]

        inputsElements =
            function.inputs |> Array.indexedMap (\i -> \inp -> genInput moduleId name i inp inputs)

        btn =
            row []
                [ Input.button
                    (accentButton ++ [ width <| Element.px 100, paddingXY 0 (S.baseRem 0.5), Font.center ])
                    { onPress = Just <| CallFunction id moduleId name, label = text "Call Function" }
                ]

        outputs =
            function.outputs
    in
    column [ spacing 12, fillWidth, Background.blackAlpha 40, padding 10 ] ([ nameEl ] ++ Array.toList inputsElements ++ [ btn ])


genInput : String -> String -> Int -> String -> Inputs -> Element Msg
genInput moduleId functionId idx fieldType inputs =
    Input.text [ width <| Element.px 400 ]
        { onChange = UpdateInput moduleId functionId idx
        , text = inputs |> getInputText moduleId functionId idx
        , placeholder = Just (Input.placeholder [] (text fieldType))
        , label = Input.labelHidden fieldType
        }


getInputText : String -> String -> Int -> Inputs -> String
getInputText moduleId functionId idx inputs =
    case Dict.get moduleId inputs of
        Just f ->
            f |> getInputFromFunction functionId idx

        Nothing ->
            ""


getInputFromFunction : String -> Int -> Dict String (Array String) -> String
getInputFromFunction functionId idx dic =
    case Dict.get functionId dic of
        Just arr ->
            Maybe.withDefault "" (Array.get idx arr)

        Nothing ->
            ""
