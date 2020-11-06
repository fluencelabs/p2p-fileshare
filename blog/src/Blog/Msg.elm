module Blog.Msg exposing (..)


type Msg
    = SetChatId String
    | SetName String
    | SetCurrentMessage String
    | JoinChat
    | SendMessage
    | CreateChat
    | ConnectedToChat
    | NewMsg String String
    | NoOp
