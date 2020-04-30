module Conn.Msg exposing (Msg(..))

import Conn.Model exposing (Peer, Relay)


type Msg
    = SetRelay Relay
    | ChoosingRelay Bool
    | RelayDiscovered Relay
    | RelayConnected Relay
    | SetPeer Peer
    | NoOp
