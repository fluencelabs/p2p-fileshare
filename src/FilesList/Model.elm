module FilesList.Model exposing (FileEntry, Model, Status(..), emptyFilesList)

import Bytes exposing (Bytes)


type Status
    = Prepared
    | Advertised
    | Seeding Int
    | Requested
    | Loaded


type alias FileEntry =
    { imageType : Maybe String
    , bytes : Maybe Bytes
    , hash : String
    , status : Status
    , logs : List String
    , logsVisible : Bool
    }


type alias Model =
    { files : List FileEntry
    }


emptyFilesList : Model
emptyFilesList =
    { files = []
    }
