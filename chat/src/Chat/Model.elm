module Chat.Model exposing (..)


type alias Message =
    { msg : String
    , name : String
    , id : Int
    , replyTo : Maybe Int
    }


type alias Model =
    { currentChatId : String
    , name : String
    , joinName : String
    , messages : List Message
    , currentMsg : String
    , replyTo : Maybe Int
    , chatId: String
    }


emptyChatModel : Model
emptyChatModel =
    { currentChatId = "", name = "", joinName = "", messages = [], currentMsg = "", replyTo = Nothing, chatId = "" }
