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
import NetworkMap.Interfaces.Model exposing (Arg, Function, Inputs, Model, Module)
import NetworkMap.Interfaces.Msg exposing (Msg(..))
import NetworkMap.Interfaces.Port as Port


getArgs : String -> String -> Inputs -> Array Arg
getArgs moduleName fname inputs =
    let
        args =
            inputs |> Dict.get moduleName |> andThen (Dict.get fname)
    in
    Maybe.withDefault Array.empty args


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetInterface peerId ->
            ( model, Port.interfacesRequest { command = "get_interface", id = Just peerId, call = Nothing } )

        CallFunction id moduleName fname ->
            let
                args =
                    model.inputs |> getArgs moduleName fname

                argsM =
                    if Array.isEmpty args then
                        Nothing

                    else
                        Just <| Array.toList args

                call =
                    { moduleName = moduleName, fname = fname, args = argsM }
            in
            ( model, Port.interfacesRequest { command = "call", id = Just id, call = Just call } )

        AddInterface interface ->
            let
                inputs =
                    modulesToInputs interface.modules
            in
            ( { model | interface = Just interface, inputs = inputs }, Cmd.none )

        UpdateInput moduleId functionId idx input ->
            let
                updated =
                    model.inputs |> Dict.update moduleId (moduleUpdate input functionId idx)
            in
            ( { model | inputs = updated }, Cmd.none )

        AddResult callResult ->
            let
                updated =
                    model.results |> Dict.update callResult.moduleName (resultUpdate callResult.result callResult.fname)
            in
            ( { model | results = updated }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


resultUpdate : String -> String -> Maybe (Dict String String) -> Maybe (Dict String String)
resultUpdate value fname old =
    case old of
        Maybe.Just o ->
            Just (o |> Dict.insert fname value)

        Maybe.Nothing ->
            let
                newDict =
                    Dict.empty
            in
            Just (newDict |> Dict.insert fname value)


modulesToInputs : Dict String Module -> Inputs
modulesToInputs modules =
    modules |> Dict.map (\_ -> \m -> functionsToBlankInputs m.functions)


functionsToBlankInputs : Dict String Function -> Dict String (Array String)
functionsToBlankInputs functions =
    functions |> Dict.map (\_ -> \f -> Array.initialize (Array.length f.input_types) (always ""))


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
