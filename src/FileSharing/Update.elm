module FileSharing.Update exposing (..)

{-| Copyright 2020 Fluence Labs Limited

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

-}

import FileSharing.AddFile.Msg
import FileSharing.AddFile.Update
import FileSharing.FilesList.Msg
import FileSharing.FilesList.Update
import FileSharing.Model exposing (Model)
import FileSharing.Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddFileMsg m ->
            updateAddFile m model

        FilesListMsg m ->
            updateFilesList m model

        NoOp ->
            ( model, Cmd.none )


updateAddFile : FileSharing.AddFile.Msg.Msg -> Model -> ( Model, Cmd Msg )
updateAddFile msg model =
    let
        ( resultModel, resultCmd ) =
            FileSharing.AddFile.Update.update msg model.addFile
    in
    ( { model | addFile = resultModel }, Cmd.map AddFileMsg resultCmd )


updateFilesList : FileSharing.FilesList.Msg.Msg -> Model -> ( Model, Cmd Msg )
updateFilesList msg model =
    let
        ( resultModel, resultCmd ) =
            FileSharing.FilesList.Update.update msg model.filesList
    in
    ( { model | filesList = resultModel }, Cmd.map FilesListMsg resultCmd )
