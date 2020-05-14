module FilesList.Msg exposing (Msg(..))

type Msg
    = NoOp
    | FileUploading String
    | FileUploaded String
    | FileDownloading String
    | FileAdvertised String (Maybe String)
    | FileLog String String
    | FileAsked String
    | FileRequested String
    | FileLoaded String (Maybe String)
    | DownloadFile String
    | Copy String
    | Copied String
    | ReplaceCopyMessage String
    | SetLogsVisible String Bool
