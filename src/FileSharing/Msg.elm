module FileSharing.Msg exposing (..)

import AddFile.Msg
import FilesList.Msg

type Msg
    = NoOp
    | AddFileMsg AddFile.Msg.Msg
    | FilesListMsg FilesList.Msg.Msg