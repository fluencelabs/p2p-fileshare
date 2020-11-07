module Chat.Msg exposing (..)

import Chat.Model exposing (Message)


type Msg
    = SetChatId String
    | SetName String
    | SetCurrentMessage String
    | JoinChat
    | SendMessage
    | CreateChat
    | ConnectedToChat
    | NewMsg Message
    | SetReplyTo (Maybe Int)
    | NoOp
