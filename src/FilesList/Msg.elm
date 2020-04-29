module FilesList.Msg exposing (Msg(..))

import Bytes exposing (Bytes)
import File exposing (File)


type Msg
    = NoOp
    | AddFile File Bytes String
    | SetLogsVisible String Bool
