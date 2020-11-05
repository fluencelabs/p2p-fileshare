module Chat.Model exposing (..)


type alias Member =
    { peerId : String
    , name : String
    }


type alias Model =
    { chatId : String
    , name : String
    , members : List Member
    }


emptyChatModel : Model
emptyChatModel =
    { chatId = "", name = "", members = [] }
