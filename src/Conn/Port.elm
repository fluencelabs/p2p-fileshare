port module Conn.Port exposing (..)

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

import Conn.Model exposing (Model, RelayInput)
import Conn.Msg exposing (Msg(..))
import Conn.Relay exposing (Peer, Relay)


type alias Command =
    { command : String, id : Maybe String, connectTo : Maybe RelayInput }


type alias Event =
    { event : String, peer : Maybe Peer, relay : Maybe Relay, errorMsg : Maybe String }


port connRequest : Command -> Cmd msg

command : String -> Command
command c =
    { command = c, id = Nothing, connectTo = Nothing }


port connReceiver : (Event -> msg) -> Sub msg


eventToMsg : Event -> Msg
eventToMsg event =
    Maybe.withDefault NoOp <|
        case event.event of
            "relay_discovered" ->
                Maybe.map RelayDiscovered event.relay

            "relay_connected" ->
                Maybe.map RelayConnected event.relay

            "relay_connecting" ->
                Just RelayConnecting

            "set_peer" ->
                Maybe.map SetPeer event.peer

            "error" ->
                Maybe.map Error event.errorMsg

            _ ->
                Nothing


subscriptions : Model -> Sub Msg
subscriptions _ =
    connReceiver eventToMsg
