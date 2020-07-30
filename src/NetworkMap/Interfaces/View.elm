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
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Ions.Background as Background
import Ions.Border as B
import Ions.Font as F
import Ions.Size as S
import Maybe exposing (withDefault)
import NetworkMap.Interfaces.Model exposing (Function, Inputs, Interface, Model, Module, Results)
import NetworkMap.Interfaces.Msg exposing (Msg(..))
import Palette exposing (accentButton, fillWidth, letterSpacing, limitLayoutWidth)
import Screen.Model as Screen


view : Screen.Model -> Model -> Element Msg
view screen model =
    let
        modulesEl =
            (model.interfaces
                |> interfacesForms model.id model.inputs model.results model.isOpenedInterfaces
            )
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
                { onPress = Just <| GetInterfaces model.id
                , label =
                    Element.el
                        []
                        (Element.text "Get Interfaces")
                }
    in
    row [ limitLayoutWidth, Background.white, centerX ]
        [ el [ alignRight, padding 5 ] <| btn
        ]

interfacesForms : String -> Inputs -> Results -> Dict String Bool -> List Interface -> Element Msg
interfacesForms id inputs results isOpenedInterfaces interfaces  =
    let
        interfacesF = interfaces |> List.map (\i -> interfaceForms id inputs results i (withDefault False (isOpenedInterfaces |> Dict.get i.name)))
    in
        column [ fillWidth, spacing 10 ] interfacesF

interfaceForms : String -> Inputs -> Results -> Interface -> Bool -> Element Msg
interfaceForms id inputs results interface isOpened =
    let

        nameEl =
            row [ fillWidth, centerX, padding 8 ] [ blockName "Service: ", blockValue <| text interface.name ]
        actionButton =
            Input.button
                [ padding 10, Background.blackAlpha 60 ]
                { onPress = Just <| ShowInterface interface.name, label = text (if isOpened then "Hide" else "Show") }
        modules =
            interface.modules
        modulesList = if (isOpened) then (modules |> List.map (\mod -> moduleForms id interface.name inputs results mod)) else [Element.none]
    in
    column [ fillWidth, Background.blackAlpha 20, padding 10, spacing 10 ] ([nameEl, actionButton] ++ modulesList)


blockName : String -> Element Msg
blockName t =
    el [ width (fillPortion 2), letterSpacing, F.gray ] <| Element.text t


blockValue : Element Msg -> Element Msg
blockValue t =
    el [ width (fillPortion 5), Font.size 16 ] <| t


moduleForms : String -> String -> Inputs -> Results -> Module -> Element Msg
moduleForms id serviceId inputs results mod =
    let
        nameEl =
            row [ fillWidth, centerX, padding 8 ] [ blockName "Module: ", blockValue <| text mod.name ]

        functions =
            mod.functions
    in
    column [ fillWidth, Background.blackAlpha 40, padding 20, spacing 10 ]
        ([ nameEl ]
            ++ (functions |> List.map (\f -> functionForms id inputs (getResult serviceId mod.name f.name results) serviceId mod.name f))
        )


getResult : String -> String -> String -> Results -> Maybe String
getResult serviceId moduleId fname results =
    results |> Dict.get (serviceId, moduleId, fname)


functionForms : String -> Inputs -> Maybe String -> String -> String -> Function -> Element Msg
functionForms id inputs result serviceId moduleId function =
    let
        nameEl =
            row [ fillWidth, centerX ] [ blockName "Function: ", blockValue <| text function.name ]

        inputsElements =
            function.input_types |> Array.indexedMap (\i -> \inp -> genInput serviceId moduleId function.name i inp inputs)

        btn =
            row []
                [ Input.button
                    (accentButton ++ [ width <| Element.px 100, paddingXY 0 (S.baseRem 0.5), Font.center ])
                    { onPress = Just <| CallFunction id serviceId moduleId function.name, label = text "Call Function" }
                ]

        resultEl =
            case result of
                Just r ->
                    text r

                Nothing ->
                    Element.none

        outputs =
            row [ fillWidth, centerX ]
                [ blockName "Output Types"
                , blockValue <| text ("[ " ++ String.join ", " (Array.toList function.output_types) ++ " ]")
                ]
    in
    column [ spacing 12, fillWidth, Background.blackAlpha 40, B.width1 B.AllSides, Border.dotted, padding 10 ]
        ([ nameEl ] ++ Array.toList inputsElements ++ [ outputs, resultEl, btn ])


genInput : String -> String -> String -> Int -> String -> Inputs -> Element Msg
genInput serviceId moduleId functionId idx fieldType inputs =
    Input.text [ width <| Element.px 400 ]
        { onChange = UpdateInput serviceId moduleId functionId idx
        , text = inputs |> getInputText serviceId moduleId functionId idx
        , placeholder = Just (Input.placeholder [] (text fieldType))
        , label = Input.labelHidden fieldType
        }


getInputText : String -> String -> String -> Int -> Inputs -> String
getInputText serviceId moduleId functionId idx inputs =
    case Dict.get (serviceId, moduleId, functionId) inputs of
        Just f ->
            Maybe.withDefault "" (Array.get idx f)

        Nothing ->
            ""


getInputFromFunction : String -> Int -> Dict String (Array String) -> String
getInputFromFunction functionId idx dic =
    case Dict.get functionId dic of
        Just arr ->
            Maybe.withDefault "" (Array.get idx arr)

        Nothing ->
            ""
