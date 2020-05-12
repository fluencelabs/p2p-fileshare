module Update exposing (update)

import AddFile.Update
import Conn.Update
import FilesList.Update
import Model exposing (Model)
import Msg exposing (..)
import NetworkMap.Update


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

updateNetworkMap =
    liftUpdate .networkMap (\c -> \m -> { m | networkMap = c }) NetworkMapMsg NetworkMap.Update.update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ConnMsg m ->
            updateConn m model

        AddFileMsg m ->
            updateAddFile m model

        FilesListMsg m ->
            updateFilesList m model

        NetworkMapMsg m ->
            updateNetworkMap m model

        _ ->
            ( model, Cmd.none )
