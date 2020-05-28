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

module Conn.Msg exposing (..)

type alias Peer =
    { id : String, seed: Maybe String }


type alias Relay =
    { peer : Peer
    , host : Maybe String
    , dns : Maybe String
    , pport : Int
    }

type Msg
    = SetRelay Relay
    | ConnectToRandomRelay
    | UpdatePeerInput String
    | UpdateRelayHostInput String
    | UpdateRelayPortInput String
    | UpdateRelayPrivateKeyInput String
    | Connect
    | GeneratePeer
    | ChoosingRelay Bool
    | RelayDiscovered Relay
    | RelayConnected Relay
    | RelayConnecting
    | SetPeer Peer
    | Error String
    | NoOp
