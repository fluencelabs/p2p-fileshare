module Chat.Model exposing (..)

type alias Model =
    { chatId : String

    }

emptyChatModel : Model
emptyChatModel =
    {chatId = ""}