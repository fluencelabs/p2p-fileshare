module Chat.Update exposing (..)

import Chat.Model exposing (Model)
import Chat.Msg exposing (Msg(..))
import Chat.Port


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetChatId chatId ->
            ( { model | chatId = chatId }, Cmd.none )

        SetName name ->
            ( { model | name = name }, Cmd.none )

        SetCurrentMessage message ->
            ( { model | currentMsg = message }, Cmd.none )

        JoinChat ->
            ( model, Chat.Port.chatRequest { command = "join", chatId = Just model.chatId, name = Just model.name, msg = Nothing } )

        CreateChat ->
            ( model, Chat.Port.chatRequest { command = "create", chatId = Nothing, name = Just model.name, msg = Nothing } )

        SendMessage ->
            ( model, Chat.Port.chatRequest { command = "send_message", chatId = Nothing, name = Just model.name, msg = Just model.currentMsg } )

        ConnectedToChat ->
            ( model, Cmd.none )

        NewMsg m ->
            ( { model | messages = m :: model.messages }, Cmd.none )

        SetReplyTo maybeId ->
            ( { model | replyTo = maybeId }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

