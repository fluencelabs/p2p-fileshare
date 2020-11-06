module Blog.Model exposing (..)


type alias Message =
    { msg : String
    , name : String
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
