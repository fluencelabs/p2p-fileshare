module FileSharing.AddFile.Update exposing (update)

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

import FileSharing.AddFile.Model exposing (Model)
import FileSharing.AddFile.Msg exposing (Msg(..))
import FileSharing.AddFile.Port
import Platform.Cmd exposing (Cmd(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetVisible v ->
            ( { model | visible = v }, Cmd.none )

        ChangeIpfsHash hash ->
            ( { model | ipfsHash = hash }, Cmd.none )

        DownloadIpfs ->
            ( { model | ipfsHash = "" }, FileSharing.AddFile.Port.addFileByHash model.ipfsHash )

        FileRequested ->
            ( model, FileSharing.AddFile.Port.selectFile () )
