module Conn.Msg exposing (..)

import Conn.Relay exposing (Peer, Relay)


type Msg
    = SetRelay Relay
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
