module Conn.Model exposing (..)

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

import Conn.Msg exposing (Msg(..))
import Conn.Relay exposing (Peer, Relay, RelayInput)
import Utils exposing (run)


type Status
    = NotConnected
    | Connecting
    | Connected


type alias Model =
    { peer : Peer
    , relay : Maybe Relay
    , status : Status
    , discovered : List Relay
    , choosing : Bool
    , isAdmin : Bool
    , relayInput : RelayInput
    , errorMsg : String
    }


emptyConn : Bool -> RelayInput -> List Relay -> ( Model, Cmd Msg )
emptyConn isAdmin defaultRelayInput relays =
    let
        emptyModel =
            { peer = { id = "-----", privateKey = Nothing }
            , relay = Nothing
            , status = NotConnected
            , discovered = relays
            , choosing = False
            , isAdmin = isAdmin
            , relayInput = defaultRelayInput
            , errorMsg = ""
            }

        cmd =
            if isAdmin then
                Cmd.none

            else
                run <| GeneratePeer
    in
    ( emptyModel, cmd )
