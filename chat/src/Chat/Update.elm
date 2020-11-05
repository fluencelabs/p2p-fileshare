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

        JoinChat ->
            ( model, Chat.Port.chatRequest { command = "join", chatId = Just model.chatId, name = Just model.name } )

        CreateChat ->
            ( model, Chat.Port.chatRequest { command = "create", chatId = Nothing, name = Just model.name } )

        ConnectedToChat ->
            ( model, Cmd.none )

        NewMember peerId name ->
            ( model, Cmd.none )

        NewMsg peerId m ->
            ( model, Cmd.none )

        NameChanged peerId name ->
            ( model, Cmd.none )

        RelayChanged peerId relay ->
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
