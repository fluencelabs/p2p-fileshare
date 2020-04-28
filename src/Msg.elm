module Msg exposing (Msg(..))

import AddFile.Msg
import Conn.Msg
import FilesList.Msg


type Msg
    = NoOp
    | ConnMsg Conn.Msg.Msg
    | AddFileMsg AddFile.Msg.Msg
    | FilesListMsg FilesList.Msg.Msg
