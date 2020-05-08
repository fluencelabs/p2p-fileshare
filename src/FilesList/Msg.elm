module FilesList.Msg exposing (Msg(..))

type Msg
    = NoOp
    | FileAdvertised String (Maybe String) (Maybe String)
    | FileLog String String
    | FileAsked String
    | FileRequested String
    | FileLoaded String (Maybe String) (Maybe String)
    | DownloadFile String
    | SetLogsVisible String Bool
