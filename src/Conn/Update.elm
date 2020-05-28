module Conn.Update exposing (update)

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

import Conn.Model exposing (Model, Status(..))
import Conn.Msg exposing (Msg(..))
import Conn.Port exposing (command)
import Conn.Relay exposing (setHost, setPeerId, setPort, setSeed)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Error errorMsg ->
            ( { model | errorMsg = errorMsg }, Cmd.none)
        Connect ->
            ( model, Conn.Port.connRequest { command = "connect_to", id = Nothing, connectTo = Just model.relayInput } )
        UpdateRelayHostInput str ->
            ( { model | relayInput = setHost str model.relayInput }, Cmd.none)
        UpdateRelayPortInput str ->
            ( { model | relayInput = setPort str model.relayInput }, Cmd.none)
        UpdateRelayPrivateKeyInput str ->
            ( { model | relayInput = setSeed str model.relayInput }, Cmd.none)
        UpdatePeerInput str ->
            ( { model | relayInput = setPeerId str model.relayInput }, Cmd.none)
        SetRelay relay ->
            ( { model | relay = Nothing }, Conn.Port.connRequest { command = "set_relay", id = Just relay.peer.id, connectTo = Nothing } )

        GeneratePeer ->
            ( model, Conn.Port.connRequest <| command "generate_peer" )

        ConnectToRandomRelay ->
            ( model, Conn.Port.connRequest <| command "random_connect" )

        ChoosingRelay choosing ->
            ( { model | choosing = choosing }, Cmd.none )

        RelayDiscovered relay ->
            let
                relays =
                    model.discovered

                alreadyKnown =
                    List.any (\r -> r.peer.id == relay.peer.id) relays
            in
            if alreadyKnown then
                ( model, Cmd.none )

            else
                ( { model | discovered = relays ++ [ relay ] }, Cmd.none )

        RelayConnected relay ->
                ( { model | relay = Just relay, status = Connected, errorMsg = "" }, Cmd.none )

        RelayConnecting ->
                ( { model | status = Connecting }, Cmd.none )

        SetPeer peer ->
            let
                cmd =
                    if model.isAdmin then
                        Cmd.none
                    else
                        -- if it is not an admin page, connect to a random node
                        Conn.Port.connRequest <| command "random_connect"
            in ( { model | peer = peer, relayInput = setSeed (Maybe.withDefault "" peer.seed) model.relayInput },  cmd)

        NoOp ->
            ( model, Cmd.none )
