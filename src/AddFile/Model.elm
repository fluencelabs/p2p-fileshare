module AddFile.Model exposing (..)

import Bytes exposing (Bytes)
import File exposing (File)


type alias CalcHashProgress =
    { file : File, bytes : Bytes }


type alias Model =
    { visible : Bool
    , ipfsHash : String
    , calculatingHashFor : Maybe CalcHashProgress
    }


emptyAddFile : Model
emptyAddFile =
    { visible = False
    , ipfsHash = ""
    , calculatingHashFor = Nothing
    }
