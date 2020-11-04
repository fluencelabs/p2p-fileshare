module Chat.Model exposing (..)

type alias Member =
    { peerId: String
    , name: String
    }

type alias Model =
    { chatId : String
    , members: List (Member)
    }

emptyChatModel : Model
emptyChatModel =
    { chatId = "", members = [] }