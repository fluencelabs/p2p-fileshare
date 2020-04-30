module FilesList.Msg exposing (Msg(..))

import Bytes exposing (Bytes)
import File exposing (File)


type Msg
    = NoOp
    | AddFile File Bytes String
    | FileAdvertised String
    | FileLog String String
    | FileAsked String
    | FileRequested String
    | FileLoaded String (List Int) (Maybe String)
    | DownloadFile String
    | SetLogsVisible String Bool
