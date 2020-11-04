module Chat.Update exposing (..)

import Chat.Model exposing (Model)
import Chat.Msg exposing (Msg(..))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetChatId chatId ->
            ( { model | chatId = chatId }, Cmd.none )

        JoinChat ->
            --( model, Conn.Port.connRequest { command = "connect_to", id = Nothing, connectTo = Just model.relayInput } )
            ( model, Cmd.none )

        CreateChat ->
            ( model, Cmd.none )

        ConnectedToChat ->
            ( model, Cmd.none )
