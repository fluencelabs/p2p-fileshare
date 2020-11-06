module Chat.Model exposing (..)


type alias Message =
    { msg : String
    , name : String
    , id : Int
    }


type alias Model =
    { chatId : String
    , name : String
    , messages : List Message
    , currentMsg : String
    }


emptyChatModel : Model
emptyChatModel =
    { chatId = "", name = "", messages = [], currentMsg = "" }
