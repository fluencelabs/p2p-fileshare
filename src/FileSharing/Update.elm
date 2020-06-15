module FileSharing.Update exposing (..)

import AddFile.Msg
import AddFile.Update
import FileSharing.Model exposing (Model)
import FileSharing.Msg exposing (Msg(..))
import FilesList.Msg
import FilesList.Update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddFileMsg m ->
            updateAddFile m model
        FilesListMsg m ->
            updateFilesList m model
        NoOp ->
            ( model, Cmd.none )

updateAddFile : AddFile.Msg.Msg -> Model -> ( Model, Cmd Msg )
updateAddFile msg model =
    let
        (resultModel, resultCmd) = AddFile.Update.update msg model.addFile
    in
        ( { model | addFile = resultModel }, Cmd.map AddFileMsg resultCmd)


updateFilesList : FilesList.Msg.Msg -> Model -> ( Model, Cmd Msg )
updateFilesList msg model =
    let
        (resultModel, resultCmd) = FilesList.Update.update msg model.filesList
    in
        ( { model | filesList = resultModel }, Cmd.map FilesListMsg resultCmd)