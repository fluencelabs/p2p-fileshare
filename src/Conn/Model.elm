module Conn.Model exposing (..)

import Conn.Msg exposing (Msg(..), Peer, Relay)
import Utils exposing (run)

type Status
    = NotConnected
    | Connecting
    | Connected

type alias Model =
    { peer : Peer
    , relay : Maybe Relay
    , status: Status
    , discovered : List Relay
    , choosing : Bool
    , isAdmin : Bool
    , peerInput : String
    , relayInput : String
    }


emptyConn : Bool -> ( Model, Cmd Msg )
emptyConn isAdmin =
    let
        emptyModel =
            { peer = { id = "-----" }
            , relay = Nothing
            , status = NotConnected
            , discovered = []
            , choosing = False
            , isAdmin = isAdmin
            , peerInput = "peerIn"
            , relayInput = "relayInput"
            }
        cmd = if (isAdmin) then
                Cmd.none
            else
                run <| GeneratePeer
    in
        ( emptyModel, cmd )
