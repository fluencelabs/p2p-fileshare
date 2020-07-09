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
import NetworkMap.Interfaces.Model exposing (Function, Inputs, Interface, Model, Module, Results)
import NetworkMap.Interfaces.Msg exposing (Msg(..))
import Palette exposing (accentButton, fillWidth, letterSpacing, limitLayoutWidth)
import Screen.Model as Screen


view : Screen.Model -> Model -> Element Msg
view screen model =
    let
        modulesEl =
            (model.interface
                |> Maybe.map (interfaceForms model.id model.inputs model.results)
            )
                |> Maybe.withDefault Element.none
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


interfaceForms : String -> Inputs -> Results -> Interface -> Element Msg
interfaceForms id inputs results interface =
    let
        modules =
            interface.modules
    in
    column [ fillWidth, spacing 10 ] (Dict.values (modules |> Dict.map (\n -> \m -> moduleForms id n inputs results m)))


blockName : String -> Element Msg
blockName t =
    el [ width (fillPortion 2), letterSpacing, F.gray ] <| Element.text t


blockValue : Element Msg -> Element Msg
blockValue t =
    el [ width (fillPortion 5), Font.size 16 ] <| t


moduleForms : String -> String -> Inputs -> Results -> Module -> Element Msg
moduleForms id name inputs results mod =
    let
        nameEl =
            row [ fillWidth, centerX, padding 8 ] [ blockName "Module: ", blockValue <| text name ]

        functions =
            mod.functions
    in
    column [ fillWidth, Background.blackAlpha 20, padding 10, spacing 10 ]
        ([ nameEl ]
            ++ Dict.values (functions |> Dict.map (\n -> \f -> functionForms id n inputs (getResult name n results) name f))
        )


getResult : String -> String -> Results -> Maybe String
getResult moduleId fname results =
    results |> Dict.get moduleId |> Maybe.andThen (\d -> d |> Dict.get fname)


functionForms : String -> String -> Inputs -> Maybe String -> String -> Function -> Element Msg
functionForms id name inputs result moduleId function =
    let
        nameEl =
            row [ fillWidth, centerX ] [ blockName "Function: ", blockValue <| text name ]

        inputsElements =
            function.input_types |> Array.indexedMap (\i -> \inp -> genInput moduleId name i inp inputs)

        btn =
            row []
                [ Input.button
                    (accentButton ++ [ width <| Element.px 100, paddingXY 0 (S.baseRem 0.5), Font.center ])
                    { onPress = Just <| CallFunction id moduleId name, label = text "Call Function" }
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
