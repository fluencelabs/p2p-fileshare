module Conn.Msg exposing (..)

type alias Peer =
    { id : String }


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
    | UpdateRelayInput String
    | Connect
    | GeneratePeer
    | ChoosingRelay Bool
    | RelayDiscovered Relay
    | RelayConnected Relay
    | RelayConnecting
    | SetPeer Peer
    | NoOp
