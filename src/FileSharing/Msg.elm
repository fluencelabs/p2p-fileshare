module FileSharing.Msg exposing (..)

import FileSharing.AddFile.Msg
import FileSharing.FilesList.Msg


type Msg
    = NoOp
    | AddFileMsg FileSharing.AddFile.Msg.Msg
    | FilesListMsg FileSharing.FilesList.Msg.Msg
