module NetworkMap.Interfaces.Update exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import Maybe exposing (andThen)
import NetworkMap.Interfaces.Port as Port
import NetworkMap.Interfaces.Model exposing (Arg, Function, Inputs, Model, Module)
import NetworkMap.Interfaces.Msg exposing (Msg(..))

getArgs : String -> String -> Inputs -> Array Arg
getArgs moduleName fname inputs =
    let
        args = inputs |> Dict.get moduleName |> andThen (Dict.get fname)
    in
        Maybe.withDefault Array.empty args

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetInterface peerId ->
            ( model, Port.interfacesRequest { command = "get_interface", id = Just peerId, call = Nothing } )

        CallFunction id moduleName fname ->
            let
                args = model.inputs |> getArgs moduleName fname
                call = { moduleName = moduleName, fname = fname, args = Array.toList args}
            in
                ( model, Port.interfacesRequest { command = "call", id = Just id, call = Just call } )

        AddInterface interface ->
            let
                inputs = modulesToInputs interface.modules

            in
                ( { model | interface = Just interface, inputs = inputs }, Cmd.none )

        UpdateInput moduleId functionId idx input ->
            let
                updated = model.inputs |> Dict.update moduleId (moduleUpdate input functionId idx)
            in
                ( { model | inputs = updated }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

modulesToInputs : List Module -> Inputs
modulesToInputs modules =
    modules |> List.foldl (\m -> \d -> d |> Dict.insert m.name (functionsToDic m.functions)) Dict.empty

functionsToDic : List Function -> Dict String (Array String)
functionsToDic functions =
    functions |> List.foldl (\f -> \d -> d |> Dict.insert f.name (Array.initialize (Array.length f.inputs) (always ""))) Dict.empty

moduleUpdate: String -> String -> Int -> Maybe (Dict String (Array String)) -> Maybe (Dict String (Array String))
moduleUpdate input functionId idx old =
    case old of
        Just o ->
            Just (o |> Dict.update functionId (functionUpdate input idx))
        Nothing ->
            old

functionUpdate: String -> Int -> Maybe ((Array String)) -> Maybe ((Array String))
functionUpdate input idx old =
    case old of
        Just o ->
            Just (o |> Array.set idx input)

        Nothing ->
            old