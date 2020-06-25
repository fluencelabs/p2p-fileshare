module NetworkMap.Interfaces.Msg exposing (..)

import NetworkMap.Interfaces.Model exposing (Interface)
type Msg
    = GetInterface String
    | AddInterface Interface
    | UpdateInput String String Int String
    | NoOp
