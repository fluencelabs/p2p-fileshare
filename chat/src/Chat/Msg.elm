module Chat.Msg exposing (..)


type Msg
    = SetChatId String
    | SetName String
    | JoinChat
    | CreateChat
    | ConnectedToChat
    | NewMember String String
    | NewMsg String String
    | NameChanged String String
    | RelayChanged String String
    | NoOp
