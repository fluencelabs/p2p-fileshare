module AddFile.Model exposing (..)

import File exposing (File)


type alias Model =
    { visible : Bool
    , ipfsHash : String
    , calculatingHashFor : Maybe File
    }


emptyAddFile : Model
emptyAddFile =
    { visible = False
    , ipfsHash = ""
    , calculatingHashFor = Nothing
    }
