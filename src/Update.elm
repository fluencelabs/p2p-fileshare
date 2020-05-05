module Update exposing (update)

import AddFile.Msg
import AddFile.Update
import Conn.Update
import FilesList.Msg
import FilesList.Update
import Model exposing (Model)
import Msg exposing (..)


liftUpdate :
    (Model -> model)
    -> (model -> Model -> Model)
    -> (msg -> Msg)
    -> (msg -> model -> ( model, Cmd msg ))
    -> (msg -> Model -> ( Model, Cmd Msg ))
liftUpdate getModel setModel liftMsg updateComponent =
    \msg ->
        \model ->
            let
                m =
                    getModel model

                ( updatedComponentModel, modelCmd ) =
                    updateComponent msg m
            in
            ( setModel updatedComponentModel model
            , Cmd.map liftMsg modelCmd
            )


updateConn =
    liftUpdate .connectivity (\c -> \m -> { m | connectivity = c }) ConnMsg Conn.Update.update


updateAddFile =
    liftUpdate .addFile (\c -> \m -> { m | addFile = c }) AddFileMsg AddFile.Update.update


updateFilesList =
    liftUpdate .filesList (\c -> \m -> { m | filesList = c }) FilesListMsg FilesList.Update.update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddFileMsg (AddFile.Msg.FileReady imageType bytes hash) ->
            -- Move Ready event from AddFile to FilesList
            update (FilesListMsg <| FilesList.Msg.AddFile imageType bytes hash) model

        ConnMsg m ->
            updateConn m model

        AddFileMsg m ->
            updateAddFile m model

        FilesListMsg m ->
            updateFilesList m model

        _ ->
            ( model, Cmd.none )
