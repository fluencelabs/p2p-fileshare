module Model exposing (Model, emptyModel)

import AddFile.Model exposing (emptyAddFile)
import Conn.Model exposing (emptyConn)


type alias Model =
    { connectivity : Conn.Model.Model, addFile : AddFile.Model.Model }


emptyModel : Model
emptyModel =
    { connectivity = emptyConn
    , addFile = emptyAddFile
    }
