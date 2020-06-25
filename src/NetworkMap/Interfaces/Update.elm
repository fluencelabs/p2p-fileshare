module NetworkMap.Interfaces.Update exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)
import NetworkMap.Interfaces.Port as Port
import NetworkMap.Interfaces.Model exposing (Model)
import NetworkMap.Interfaces.Msg exposing (Msg(..))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetInterface peerId ->
            ( model, Port.interfacesRequest { command = "get_interface", id = Just peerId } )

        AddInterface interface ->
            let
                a = 1

            in
                ( { model | interface = Just interface }, Cmd.none )

        UpdateInput moduleId functionId idx input ->
            let
                updated = model.inputs |> Dict.update moduleId (moduleUpdate input functionId idx)
            in
                ( { model | inputs = updated }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

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