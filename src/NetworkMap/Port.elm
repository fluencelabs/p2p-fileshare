port module NetworkMap.Port exposing (..)

{-|
  Copyright 2020 Fluence Labs Limited

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

import Maybe exposing (andThen)
import NetworkMap.Model exposing (Certificate, Model, Peer, PeerType(..))
import NetworkMap.Msg exposing (Msg(..))


type alias Command =
    { command : String, id : Maybe String }


type alias Event =
    { event : String, cert: Maybe (String, Certificate), peerAppeared: Maybe { peer: Peer, peerType: String, updateDate: String } }

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
                    |> andThen (\peerAppeared -> stringToPeerType peerAppeared.peerType
                    |> andThen (\peerType -> Just (PeerAppeared peerAppeared.peer peerType peerAppeared.updateDate)))
            "add_cert" ->
                event.cert
                    |> Maybe.map (\(id, cert) -> CertificateAdded id cert)
            _ ->
                Nothing


subscriptions : Model -> Sub Msg
subscriptions _ =
    networkMapReceiver eventToMsg

port networkMapRequest : Command -> Cmd msg
