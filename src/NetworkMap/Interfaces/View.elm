module NetworkMap.Interfaces.View exposing (..)

import Element exposing (Element, column, text, width)
import Element.Font as Font
import Element.Input as Input
import NetworkMap.Interfaces.Msg exposing (Msg(..))
import NetworkMap.Interfaces.Model exposing (Function, Interface, Model, Module)
import Palette exposing (fillWidth)
import Screen.Model as Screen

view : Screen.Model -> Model -> Element Msg
view screen model =
    let
        modulesEl =  (model.interface |> Maybe.map interfaceForms) |> Maybe.withDefault Element.none
    in
    column [ fillWidth ]
        [modulesEl, Input.button
                 [ width <| Element.px 80 ]
             <|
                 { onPress = Just <| GetInterface model.id
                 , label =
                     Element.el
                         [ Font.underline
                         ]
                         (Element.text "Get Interfaces")
                 }]

interfaceForms : Interface -> Element Msg
interfaceForms interface =
    let
        modules = interface.modules
    in
        column [ fillWidth ] (modules |> List.map moduleForms)

moduleForms : Module -> Element Msg
moduleForms mod =
    let
        name = mod.name
        functions = mod.functions
    in
        column [ fillWidth ] ([text name] ++ (functions |> List.map (functionForms name)))

functionForms : String -> Function -> Element Msg
functionForms moduleId function =
    let
        name = function.name
        inputs = function.inputs
        outputs = function.outputs
    in
        column [ fillWidth ] ([text name] ++ (inputs |> List.map (\i -> text i)) ++ (outputs |> List.map (\o -> text o)))
