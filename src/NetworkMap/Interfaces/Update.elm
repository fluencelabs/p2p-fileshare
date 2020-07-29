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
import List.FlatMap
import Maybe exposing (withDefault)
import NetworkMap.Interfaces.Model exposing (Arg, Function, Input, Inputs, Interface, Model, Module)
import NetworkMap.Interfaces.Msg exposing (Msg(..))
import NetworkMap.Interfaces.Port as Port


getArgs : String -> String -> String -> Inputs -> Array Arg
getArgs serviceId moduleName fname inputs =
    let
        args =
            inputs |> Dict.get (serviceId, moduleName, fname)
    in
        withDefault Array.empty args


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetInterfaces peerId ->
            ( model, Port.interfacesRequest { command = "get_active_interfaces", id = Just peerId, call = Nothing } )

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
                    model.inputs |> Dict.update (serviceId, moduleId, functionId) (moduleUpdate input  idx)
            in
            ( { model | inputs = updated }, Cmd.none )

        AddResult callResult ->
            let
                updated =
                    model.results |> Dict.insert (callResult.serviceId, callResult.moduleName, callResult.fname) callResult.result
            in
            ( { model | results = updated }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

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


interfacesToInputs : List Interface -> Inputs
interfacesToInputs interfaces =
    Dict.fromList (List.FlatMap.flatMap (\i -> ( modulesToInputs i.name i.modules )) interfaces)


modulesToInputs : String -> List Module -> List Input
modulesToInputs serviceId modules =
    (List.FlatMap.flatMap (\m -> ( functionsToBlankInputs m.functions serviceId m.name )) modules)

functionsToBlankInputs : List Function -> String -> String -> List Input
functionsToBlankInputs functions serviceId moduleId =
    (functions |> (List.map (\f -> inputTypesToBlankInputs f.input_types serviceId moduleId f.name )))

inputTypesToBlankInputs : Array String -> String -> String -> String -> Input
inputTypesToBlankInputs inputs serviceId moduleId functionId =
    ((serviceId, moduleId, functionId), inputs)


moduleUpdate : String -> Int -> Maybe (Array String) -> Maybe (Array String)
moduleUpdate input idx old =
    case old of
        Just o ->
            Just (o |> Array.set idx input)

        Nothing ->
            old
