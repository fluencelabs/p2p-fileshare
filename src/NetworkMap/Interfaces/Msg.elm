module NetworkMap.Interfaces.Msg exposing (..)

import NetworkMap.Interfaces.Model exposing (Call, Interface)
type Msg
    = GetInterface String
    | AddInterface Interface
    | CallFunction String String String
    | UpdateInput String String Int String
    | NoOp
