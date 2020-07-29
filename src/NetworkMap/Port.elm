port module NetworkMap.Port exposing (..)

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
import Json.Decode exposing (Decoder, Value, array, decodeValue, field, list, string)
import Maybe exposing (andThen, map2, withDefault)
import NetworkMap.Certificates.Model exposing (Certificate)
import NetworkMap.Certificates.Msg as CertificatesMsg
import NetworkMap.Interfaces.Model exposing (CallResult, Function, Interface, Module)
import NetworkMap.Interfaces.Msg
import NetworkMap.Model exposing (Model, Peer, PeerType(..))
import NetworkMap.Msg exposing (Msg(..))


type alias Command =
    { command : String, id : Maybe String }


type alias Event =
    { event : String
    , certs : Maybe (List Certificate)
    , interface : Maybe Json.Decode.Value
    , result : Maybe CallResult
    , id : Maybe String
    , peerAppeared : Maybe { peer : Peer, peerType : String, updateDate : String }
    }


port networkMapReceiver : (Event -> msg) -> Sub msg


stringToPeerType : String -> Maybe PeerType
stringToPeerType str =
    case str of
        "peer" ->
            Just Relay

        "client" ->
            Just Client

        _ ->
            Nothing


eventToMsg : Event -> Msg
eventToMsg event =
    Maybe.withDefault NoOp <|
        case event.event of
            "peer_appeared" ->
                event.peerAppeared
                    |> andThen
                        (\peerAppeared ->
                            stringToPeerType peerAppeared.peerType
                                |> andThen (\peerType -> Just (PeerAppeared peerAppeared.peer peerType peerAppeared.updateDate False))
                        )

            "add_cert" ->
                map2
                    (\certs -> \id -> CertMsg id (CertificatesMsg.CertificatesAdded <| Array.fromList certs))
                    event.certs
                    event.id

            "add_interface" ->
                withDefault Nothing <|
                    map2
                        (\interface -> \id -> decodeJson id interface)
                        event.interface
                        event.id

            "add_result" ->
                map2
                    (\id -> \result -> InterfaceMsg id (NetworkMap.Interfaces.Msg.AddResult result))
                    event.id
                    event.result

            _ ->
                Nothing


decodeJson : String -> Value -> Maybe Msg
decodeJson id v =
    let
        interfaces =
            decodeValue decodeInterfaces v

        msg =
            case interfaces of
                Ok value ->
                    Just (InterfaceMsg id (NetworkMap.Interfaces.Msg.AddInterfaces <| value))

                Err error ->
                    Nothing
    in
    msg


decodeStringList : Decoder (Array String)
decodeStringList =
    array string


decodeFunction : Decoder Function
decodeFunction =
    Json.Decode.map3 Function
        (field "name" string)
        (field "input_types" decodeStringList)
        (field "output_types" decodeStringList)


decodeInterfaces : Decoder (List Interface)
decodeInterfaces =
    list decodeInterface


decodeInterface : Decoder Interface
decodeInterface =
    Json.Decode.map2 Interface
        (field "name" string)
        (field "modules" (list decodeModule))


decodeModule : Decoder Module
decodeModule =
    Json.Decode.map2 Module
        (field "name" string)
        (field "functions" (list decodeFunction))


subscriptions : Model -> Sub Msg
subscriptions _ =
    networkMapReceiver eventToMsg
