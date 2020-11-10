module Chat.Model exposing (..)


type alias Message =
    { msg : String
    , name : String
    , id : Int
    , replyTo : Maybe Int
    }

 --TODO 3 models: chat with messages view, join chat view, create chat view
type alias Model =
    { currentChatId : String
    , createName : String
    , joinName : String
    , messages : List Message
    , currentMsg : String
    , replyTo : Maybe Int
    , chatId: String
    }


emptyChatModel : Model
emptyChatModel =
    { currentChatId = "", createName = "", joinName = "", messages = [], currentMsg = "", replyTo = Nothing, chatId = "" }
