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

module Conn.Model exposing (..)

import Conn.Msg exposing (Msg(..), Peer, Relay)
import Utils exposing (run)

type Status
    = NotConnected
    | Connecting
    | Connected

type alias RelayInput =
    { host : String
    , pport : String
    , peerId : String
    , seed : String
    }

emptyRelayInput : RelayInput
emptyRelayInput =
    { host = "relay01.fluence.dev"
    , pport = "19001"
    , peerId = "12D3KooWEXNUbCXooUwHrHBbrmjsrpHXoEphPwbjQXEGyzbqKnE9"
    , seed = ""
    }

setHost : String -> RelayInput -> RelayInput
setHost host input =
    { input | host = host }

setPeerId : String -> RelayInput -> RelayInput
setPeerId peerId input =
    { input | peerId = peerId }

setPort : String -> RelayInput -> RelayInput
setPort pport input =
    { input | pport = pport }

setSeed : String -> RelayInput -> RelayInput
setSeed privateKey input =
    { input | seed = privateKey }

type alias Model =
    { peer : Peer
    , relay : Maybe Relay
    , status: Status
    , discovered : List Relay
    , choosing : Bool
    , isAdmin : Bool
    , relayInput : RelayInput
    , errorMsg : String
    }


emptyConn : Bool -> ( Model, Cmd Msg )
emptyConn isAdmin =
    let
        emptyModel =
            { peer = { id = "-----", seed = Nothing }
            , relay = Nothing
            , status = NotConnected
            , discovered = []
            , choosing = False
            , isAdmin = isAdmin
            , relayInput = emptyRelayInput
            , errorMsg = ""
            }
        cmd = if (isAdmin) then
                Cmd.none
            else
                run <| GeneratePeer
    in
        ( emptyModel, cmd )
