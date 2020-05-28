{-|
  Copyright 2020 Fluence Labs Limited

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

module FilesList.Update exposing (update)

import FilesList.Model exposing (FileEntry, Model, Status(..))
import FilesList.Msg exposing (Msg(..))
import FilesList.Port
import Process
import Task


updateEntry : Model -> String -> (FileEntry -> FileEntry) -> Model
updateEntry model hash upd =
    let
        updateFile entry =
            if entry.hash == hash then
                upd entry

            else
                entry

        files =
            List.map updateFile model.files
    in
    { model | files = files }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetLogsVisible hash flag ->
            let
                updatedModel =
                    updateEntry model hash (\e -> { e | logsVisible = flag })
            in
            ( updatedModel, Cmd.none )

        Copy hash ->
            ( model, FilesList.Port.fileRequest { command = "copy", hash = Just hash } )
        Copied hash ->
            let
                replaceCopyMessageTask =
                    Process.sleep 5000 |> Task.perform (\_ -> ReplaceCopyMessage hash)

                updatedModel =
                    updateEntry model
                        hash
                        (\e ->
                            { e | hashCopied = True }
                        )
            in
            ( updatedModel, replaceCopyMessageTask )
        ReplaceCopyMessage hash ->
            let
                updatedModel =
                    updateEntry model
                        hash
                        (\e ->
                            { e | hashCopied = False }
                        )
            in
            ( updatedModel, Cmd.none )
        DownloadFile hash ->
            ( model, FilesList.Port.fileRequest { command = "download", hash = Just hash } )

        FileRequested hash ->
            if List.any (\f -> f.hash == hash) model.files then
                ( model, Cmd.none )

            else
                let
                    entry =
                        { preview = Nothing
                        , hash = hash
                        , status = Requested
                        , hashCopied = False
                        , logs = [ "just requested to download" ]
                        , logsVisible = False
                        }

                    files =
                        model.files ++ [ entry ]
                in
                ( { model | files = files }, Cmd.none )

        FileLoaded hash preview ->
            let
                updatedModel =
                    updateEntry model hash (\e -> { e | status = Loaded, preview = preview })
            in
            ( updatedModel, Cmd.none )

        FileAdvertised hash preview ->
            let
                updatedModel =
                    updateEntry model hash (\e -> { e | status = Advertised, preview = preview })
            in
            ( updatedModel, Cmd.none )

        FileUploading hash ->
            let
                updatedModel =
                    updateEntry model hash (\e -> { e | status = Uploading })
            in
            ( updatedModel, Cmd.none )

        FileUploaded hash ->
            let
                updatedModel =
                    updateEntry model hash (\e -> { e | status = Seeding 0 })
            in
            ( updatedModel, Cmd.none )

        FileDownloading hash ->
            let
                updatedModel =
                    updateEntry model hash (\e -> { e | status = Downloading })
            in
            ( updatedModel, Cmd.none )

        FileLog hash log ->
            let
                updatedModel =
                    updateEntry model hash (\e -> { e | logs = e.logs ++ [ log ] })
            in
            ( updatedModel, Cmd.none )

        FileAsked hash ->
            let
                updatedModel =
                    updateEntry model
                        hash
                        (\e ->
                            let
                                st =
                                    case e.status of
                                        Seeding i ->
                                            Seeding (i + 1)

                                        _ ->
                                            Seeding 1
                            in { e | status = st }
                        )
            in
            ( updatedModel, Cmd.none )

        _ ->
            ( model, Cmd.none )
