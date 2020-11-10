module Chat.Msg exposing (..)

import Chat.Model exposing (Message)


type Msg
    = SetChatId String
    | SetCreateName String
    | SetJoinName String
    | SetCurrentMessage String
    | JoinChat
    | SendMessage
    | CreateChat
    | ConnectedToChat
    | NewMsg Message
    | SetReplyTo (Maybe Int)
    | NoOp
