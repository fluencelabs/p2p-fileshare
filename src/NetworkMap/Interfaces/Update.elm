module NetworkMap.Interfaces.Update exposing (..)

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
import Maybe exposing (andThen)
import NetworkMap.Interfaces.Model exposing (Arg, Function, Inputs, Interface, Model, Module)
import NetworkMap.Interfaces.Msg exposing (Msg(..))
import NetworkMap.Interfaces.Port as Port


getArgs : String -> String -> String -> Dict String Inputs -> Array Arg
getArgs serviceId moduleName fname inputs =
    let
        args =
            inputs |> Dict.get serviceId |> andThen (Dict.get moduleName) |> andThen (Dict.get fname)
    in
    Maybe.withDefault Array.empty args


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetInterface peerId ->
            ( model, Port.interfacesRequest { command = "get_interface", id = Just peerId, call = Nothing } )

        CallFunction id serviceId moduleName fname ->
            let
                args =
                    model.inputs |> getArgs serviceId moduleName fname

                argsM =
                    if Array.isEmpty args then
                        Nothing

                    else
                        Just <| Array.toList args

                call =
                    { serviceId = serviceId, moduleName = moduleName, fname = fname, args = argsM }
            in
            ( model, Port.interfacesRequest { command = "call", id = Just id, call = Just call } )

        AddInterfaces interfaces ->
            let
                inputs =
                    interfacesToInputs interfaces
            in
            ( { model | interfaces = Just interfaces, inputs = inputs }, Cmd.none )

        UpdateInput serviceId moduleId functionId idx input ->
            let
                updated =
                    model.inputs |> Dict.update serviceId (interfaceUpdate input moduleId functionId idx)
            in
            ( { model | inputs = updated }, Cmd.none )

        AddResult callResult ->
            let
                updated =
                    model.results |> Dict.update callResult.serviceId (Dict.update callResult.moduleName (resultUpdate callResult.result callResult.fname))
            in
            ( { model | results = updated }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

kjrfekjjnrfeUpdate : String -> String -> String -> String -> Maybe (Dict String (Dict String String)) -> Maybe (Dict String (Dict String String))
kjrfekjjnrfeUpdate value serviceId moduleName functionName old =
    case old of
        Maybe.Just o ->
            Just (o |> Dict. functionName value)

        Maybe.Nothing ->
            let
                newDict =
                    Dict.empty
            in
            Just (newDict |> Dict.insert functionName value)

resultUpdate : String -> String -> Maybe (Dict String String) -> Maybe (Dict String String)
resultUpdate value functionName old =
    case old of
        Maybe.Just o ->
            Just (o |> Dict.insert functionName value)

        Maybe.Nothing ->
            let
                newDict =
                    Dict.empty
            in
            Just (newDict |> Dict.insert functionName value)


interfacesToInputs : List Interface -> Dict String Inputs
interfacesToInputs interfaces =
    Dict.fromList (List.map (\i -> ( i.name, modulesToInputs i.modules )) interfaces)


modulesToInputs : List Module -> Inputs
modulesToInputs modules =
    Dict.fromList (List.map (\m -> ( m.name, functionsToBlankInputs m.functions )) modules)


functionsToBlankInputs : List Function -> Dict String (Array String)
functionsToBlankInputs functions =
    Dict.fromList (functions |> List.map (\f -> ( f.name, Array.initialize (Array.length f.input_types) (always "") )))


interfaceUpdate : String -> String -> String -> Int -> Maybe Inputs -> Maybe Inputs
interfaceUpdate input moduleId functionId idx old =
    case old of
        Just o ->
            Just (o |> Dict.update moduleId (moduleUpdate input functionId idx))

        Nothing ->
            old


moduleUpdate : String -> String -> Int -> Maybe (Dict String (Array String)) -> Maybe (Dict String (Array String))
moduleUpdate input functionId idx old =
    case old of
        Just o ->
            Just (o |> Dict.update functionId (inputUpdate input idx))

        Nothing ->
            old


inputUpdate : String -> Int -> Maybe (Array String) -> Maybe (Array String)
inputUpdate input idx old =
    case old of
        Just o ->
            Just (o |> Array.set idx input)

        Nothing ->
            old
