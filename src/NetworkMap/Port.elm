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
import Json.Decode exposing (Decoder, Value, array, decodeValue, dict, field, map, map2, string)
import Maybe exposing (andThen)
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
                event.certs
                    |> andThen
                        (\certs ->
                            event.id
                                --TODO: handle certificate events in 'Certificates' module
                                |> andThen (\id -> Just (CertMsg id (CertificatesMsg.CertificatesAdded <| Array.fromList certs)))
                        )

            "add_interface" ->
                event.interface
                    |> andThen
                        (\interface ->
                            event.id |> andThen (\id -> decodeJson id interface)
                        )

            "add_result" ->
                event.result
                    |> andThen
                        (\result ->
                            event.id |> andThen (\id -> Just (InterfaceMsg id (NetworkMap.Interfaces.Msg.AddResult result)))
                        )

            _ ->
                Nothing


decodeJson : String -> Value -> Maybe Msg
decodeJson id v =
    let
        interface =
            decodeValue (field "modules" <| dict decodeModule) v

        msg =
            case interface of
                Ok value ->
                    Just (InterfaceMsg id (NetworkMap.Interfaces.Msg.AddInterface <| { modules = value }))

                Err error ->
                    Nothing
    in
    msg


decodeStringList : Decoder (Array String)
decodeStringList =
    array string


decodeFunction : Decoder Function
decodeFunction =
    map2 Function
        (field "input_types" decodeStringList)
        (field "output_types" decodeStringList)


decodeModule : Decoder Module
decodeModule =
    map Module (dict decodeFunction)


subscriptions : Model -> Sub Msg
subscriptions _ =
    networkMapReceiver eventToMsg
