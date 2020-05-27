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
    { host = ""
    , pport = ""
    , peerId = ""
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
