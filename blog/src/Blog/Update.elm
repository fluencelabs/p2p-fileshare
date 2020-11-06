module Blog.Update exposing (..)

import Blog.Model exposing (Model)
import Blog.Msg exposing (Msg(..))
import Blog.Port


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
            ( model, Blog.Port.chatRequest { command = "join", chatId = Just model.chatId, name = Just model.name, msg = Nothing } )

        CreateChat ->
            ( model, Blog.Port.chatRequest { command = "create", chatId = Nothing, name = Just model.name, msg = Nothing } )

        SendMessage ->
            ( model, Blog.Port.chatRequest { command = "send_message", chatId = Nothing, name = Just model.name, msg = Just model.currentMsg } )

        ConnectedToChat ->
            ( model, Cmd.none )

        NewMsg name m ->
            ( { model | messages = { msg = m, name = name } :: model.messages }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
