module FilesList.Model exposing (FileEntry, Model, Status(..), emptyFilesList)

import Bytes exposing (Bytes)
import File exposing (File)


type Status
    = Seeding Int


type alias FileEntry =
    { file : Maybe File
    , bytes : Maybe Bytes
    , hash : String
    , status : Status
    , logs : List String
    }


type alias Model =
    { files : List FileEntry
    }


emptyFilesList : Model
emptyFilesList =
    { files = [ { file = Nothing, bytes = Nothing, hash = "long hash", status = Seeding 1, logs = [ "entry1", "entry2" ] } ]
    }
