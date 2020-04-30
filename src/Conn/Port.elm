port module Conn.Port exposing (..)

import Conn.Model exposing (Model, Peer, Relay)
import Conn.Msg exposing (Msg(..))
import Json.Decode
import Json.Encode


type alias Command =
    { command : String, id : Maybe String }


type alias Event =
    { event : String, peer : Maybe Peer, relay : Maybe Relay }


port connRequest : Command -> Cmd msg


port connReceiver : (Event -> msg) -> Sub msg


eventToMsg : Event -> Msg
eventToMsg event =
    Maybe.withDefault NoOp <|
        case event.event of
            "relay_discovered" ->
                Maybe.map RelayDiscovered event.relay

            "set_relay" ->
                Maybe.map RelayConnected event.relay

            "set_peer" ->
                Maybe.map SetPeer event.peer

            _ ->
                Nothing


subscriptions : Model -> Sub Msg
subscriptions _ =
    connReceiver eventToMsg
