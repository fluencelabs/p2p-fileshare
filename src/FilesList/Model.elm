module FilesList.Model exposing (FileEntry, Model, Status(..), emptyFilesList)

import File exposing (File)


type Status
    = Seeding Int


type alias FileEntry =
    { file : Maybe File
    , hash : String
    , status : Status
    , logs : List String
    }


type alias Model =
    { files : List FileEntry
    }


emptyFilesList : Model
emptyFilesList =
    { files = [ { file = Nothing, hash = "long hash", status = Seeding 1, logs = [ "entry1", "entry2" ] } ]
    }
