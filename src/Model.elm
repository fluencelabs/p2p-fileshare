module Model exposing (Model, emptyModel)

import AddFile.Model exposing (emptyAddFile)
import Conn.Model exposing (emptyConn)
import FilesList.Model exposing (emptyFilesList)


type alias Model =
    { connectivity : Conn.Model.Model, addFile : AddFile.Model.Model, filesList : FilesList.Model.Model }


emptyModel : Model
emptyModel =
    { connectivity = emptyConn
    , addFile = emptyAddFile
    , filesList = emptyFilesList
    }
