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
