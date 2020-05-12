module Msg exposing (Msg(..))

import AddFile.Msg
import Conn.Msg
import FilesList.Msg
import NetworkMap.Msg


type Msg
    = NoOp
    | ConnMsg Conn.Msg.Msg
    | AddFileMsg AddFile.Msg.Msg
    | FilesListMsg FilesList.Msg.Msg
    | NetworkMapMsg NetworkMap.Msg.Msg
