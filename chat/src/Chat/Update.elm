module Chat.Update exposing (..)

import Chat.Model exposing (Model)
import Chat.Msg exposing (Msg(..))
import Chat.Port


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetChatId chatId ->
            ( { model | currentChatId = chatId }, Cmd.none )

        SetCreateName name ->
            ( { model | name = name }, Cmd.none )

        SetJoinName name ->
            ( { model | joinName = name }, Cmd.none )

        SetCurrentMessage message ->
            ( { model | currentMsg = message }, Cmd.none )

        JoinChat ->
            ( model
            , Chat.Port.chatRequest
                { command = "join"
                , chatId = Just model.currentChatId
                , name = Just model.joinName
                , msg = Nothing
                , replyTo = Nothing
                }
            )

        CreateChat ->
            ( model
            , Chat.Port.chatRequest
                { command = "create"
                , chatId = Nothing
                , name = Just model.name
                , msg = Nothing
                , replyTo = Nothing
                }
            )

        SendMessage ->
            ( { model | currentMsg = "", replyTo = Nothing }
            , Chat.Port.chatRequest
                { command = "send_message"
                , chatId = Nothing
                , name = Just model.name
                , msg = Just model.currentMsg
                , replyTo = model.replyTo
                }
            )

        ConnectedToChat chatId ->
            ( { model | chatId = chatId }, Cmd.none )

        NewMsg m ->
            ( { model | messages = m :: model.messages }, Cmd.none )

        SetReplyTo maybeId ->
            ( { model | replyTo = maybeId }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
