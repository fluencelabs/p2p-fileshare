module AddFile.Model exposing (..)


type alias Model =
    { visible : Bool
    , ipfsHash : String
    }


emptyAddFile : Model
emptyAddFile =
    { visible = False
    , ipfsHash = ""
    }
