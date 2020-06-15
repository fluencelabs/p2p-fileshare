module FileSharing.Model exposing (..)

import FileSharing.AddFile.Model exposing (emptyAddFile)
import FileSharing.FilesList.Model exposing (emptyFilesList)


type alias Model =
    { addFile : FileSharing.AddFile.Model.Model
    , filesList : FileSharing.FilesList.Model.Model
    }


emptyFileSharing : Model
emptyFileSharing =
    { addFile = emptyAddFile
    , filesList = emptyFilesList
    }
