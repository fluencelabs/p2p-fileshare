module Conn.Update exposing (update)

import Conn.Model exposing (Model, Status(..))
import Conn.Msg exposing (Msg(..))
import Conn.Port


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetRelay relay ->
            ( { model | relay = Nothing }, Conn.Port.connRequest { command = "set_relay", id = Just relay.peer.id } )

        GeneratePeer ->
            ( model, Conn.Port.connRequest { command = "generate_peer", id = Nothing } )

        ConnectToRandomRelay ->
            ( model, Conn.Port.connRequest { command = "random_connect", id = Nothing } )

        ChoosingRelay choosing ->
            ( { model | choosing = choosing }, Cmd.none )

        RelayDiscovered relay ->
            let
                relays =
                    model.discovered

                alreadyKnown =
                    List.any (\r -> r.peer.id == relay.peer.id) relays
            in
            if alreadyKnown then
                ( model, Cmd.none )

            else
                ( { model | discovered = relays ++ [ relay ] }, Cmd.none )

        RelayConnected relay ->
                ( { model | relay = Just relay, status = Connected }, Cmd.none )

        RelayConnecting ->
                ( { model | status = Connecting }, Cmd.none )

        SetPeer peer ->
            ( { model | peer = peer }, Conn.Port.connRequest { command = "random_connect", id = Nothing } )

        NoOp ->
            ( model, Cmd.none )
