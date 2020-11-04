module Chat.Msg exposing (..)

type Msg
    = SetChatId String
    | JoinChat
    | CreateChat
    | ConnectedToChat
    | NewMember String String
    | NewMsg String String
    | NameChaged String String
    | RelayChanged String String
    | NoOp