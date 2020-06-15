module FileSharing.Model exposing (..)

import AddFile.Model exposing (emptyAddFile)
import FilesList.Model exposing (emptyFilesList)

type alias Model =
    { addFile : AddFile.Model.Model
    , filesList : FilesList.Model.Model
    }

emptyFileSharing : Model
emptyFileSharing =
    { addFile = emptyAddFile
    , filesList = emptyFilesList
    }