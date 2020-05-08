module FilesList.Model exposing (FileEntry, Model, Status(..), emptyFilesList)

type Status
    = Prepared
    | Advertised
    | Seeding Int
    | Requested
    | Loaded


type alias FileEntry =
    { imageType : Maybe String
    , base64: Maybe String
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
