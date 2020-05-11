module FilesList.Msg exposing (Msg(..))

import FilesList.Model exposing (Status)
type Msg
    = NoOp
    | ChangeStatus String Status
    | FileAdvertised String (Maybe String)
    | FileLog String String
    | FileAsked String
    | FileRequested String
    | FileLoaded String (Maybe String)
    | DownloadFile String
    | SetLogsVisible String Bool
