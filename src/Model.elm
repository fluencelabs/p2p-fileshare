module Model exposing (Model, emptyModel)

import Msg exposing (Msg(..))
import AddFile.Model exposing (emptyAddFile)
import Conn.Model exposing (emptyConn)
import FilesList.Model exposing (emptyFilesList)
import NetworkMap.Model exposing (emptyNetwork)


type alias Model =
    { connectivity : Conn.Model.Model
    , addFile : AddFile.Model.Model
    , filesList : FilesList.Model.Model
    , networkMap : NetworkMap.Model.Model
    }


emptyModel : Bool -> ( Model, Cmd Msg )
emptyModel isAdmin =
    let
        (emptyConnModel, cmd) = emptyConn isAdmin
    in
        ( { connectivity = emptyConnModel
        , addFile = emptyAddFile
        , filesList = emptyFilesList
        , networkMap = emptyNetwork
        }, Cmd.batch[ Cmd.map ConnMsg cmd ])
