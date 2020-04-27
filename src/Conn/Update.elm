module Conn.Update exposing (update)

import Conn.Model exposing (Model)
import Conn.Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetRelay peer ->
            ( { model | relay = Just peer }, Cmd.none )

        ChoosingRelay choosing ->
            ( { model | choosing = choosing }, Cmd.none )
