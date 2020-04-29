module FilesList.Msg exposing (Msg(..))

import File exposing (File)


type Msg
    = NoOp
    | AddFile File String
