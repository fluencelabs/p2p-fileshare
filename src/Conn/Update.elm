module Conn.Update exposing (update)

import Conn.Model exposing (Model)
import Conn.Msg exposing (Msg(..))
import Conn.Port


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetRelay relay ->
            -- TODO send to port
            ( { model | relay = Nothing }, Conn.Port.connRequest { command = "set relay" ++ relay.peer.id } )

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
            ( { model | relay = Just relay }, Cmd.none )

        SetPeer peer ->
            ( { model | peer = peer }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
