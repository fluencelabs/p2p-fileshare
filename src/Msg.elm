module Msg exposing (Msg(..))

import AddFile.Msg
import Conn.Msg


type Msg
    = NoOp
    | ConnMsg Conn.Msg.Msg
    | AddFileMsg AddFile.Msg.Msg
