module Chat.Model exposing (..)


type alias Message =
    { msg : String
    , name : String
    , id : Int
    , replyTo : Maybe Int
    }


type alias Model =
    { chatId : String
    , name : String
    , joinName : String
    , messages : List Message
    , currentMsg : String
    , replyTo : Maybe Int
    }


emptyChatModel : Model
emptyChatModel =
    { chatId = "", name = "", joinName = "", messages = [], currentMsg = "", replyTo = Nothing }
