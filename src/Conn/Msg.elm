module Conn.Msg exposing (Msg(..))

import Conn.Model exposing (Peer, Relay)


type Msg
    = SetRelay Relay
    | RandomConnection
    | GeneratePeer
    | ChoosingRelay Bool
    | RelayDiscovered Relay
    | RelayConnected Relay
    | RelayConnecting
    | SetPeer Peer
    | NoOp
