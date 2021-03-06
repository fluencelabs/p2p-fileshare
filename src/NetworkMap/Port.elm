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
import Json.Decode exposing (Decoder, Value)
import Maybe exposing (andThen, map2, withDefault)
import NetworkMap.Certificates.Model exposing (Certificate)
import NetworkMap.Certificates.Msg as CertificatesMsg
import NetworkMap.Interfaces.Model exposing (CallResult, Function, Interface, Module)
import NetworkMap.Interfaces.Msg
import NetworkMap.Interfaces.Port exposing (decodeInterfaceJson)
import NetworkMap.Model exposing (Model, Peer, PeerType(..))
import NetworkMap.Msg exposing (Msg(..))
import NetworkMap.Services.Msg


type alias Command =
    { command : String, id : Maybe String }


type alias Event =
    { event : String
    , certs : Maybe (List Certificate)
    , interfaces : Maybe Json.Decode.Value
    , result : Maybe CallResult
    , modules : Maybe (List String)
    , id : Maybe String
    , peerAppeared : Maybe { peer : Peer, peerType : String, updateDate : String }
    , wasmUploaded : Maybe String
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

            "add_interfaces" ->
                withDefault Nothing <|
                    map2
                        (\interface -> \id -> Maybe.map (InterfaceMsg id) (decodeInterfaceJson interface))
                        event.interfaces
                        event.id

            "add_result" ->
                map2
                    (\id -> \result -> InterfaceMsg id (NetworkMap.Interfaces.Msg.AddResult result))
                    event.id
                    event.result

            "set_modules" ->
                map2
                    (\id -> \result -> ServicesMsg id (NetworkMap.Services.Msg.UpdateModules result))
                    event.id
                    event.modules

            "wasm_uploaded" ->
                Maybe.map
                    (\id -> ServicesMsg id NetworkMap.Services.Msg.WasmUploaded)
                    event.id

            _ ->
                Nothing


subscriptions : Model -> Sub Msg
subscriptions _ =
    networkMapReceiver eventToMsg
