module FilesList.Msg exposing (Msg(..))

import Bytes exposing (Bytes)
import File exposing (File)


type Msg
    = NoOp
    | AddFile Bytes String
    | FileAdvertised String
    | FileLog String String
    | FileAsked String
    | FileRequested String
    | FileLoaded String (List Int)
    | DownloadFile String
    | SetLogsVisible String Bool
