module FilesList.Model exposing (FileEntry, Model, Status(..), emptyFilesList)

type Status
    = Prepared
    | Advertised
    | Seeding Int
    | Requested
    | Loaded
    | Uploading
    | Downloading


type alias FileEntry =
    { preview : Maybe String
    , hash : String
    , status : Status
    , hashCopied : Bool
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
