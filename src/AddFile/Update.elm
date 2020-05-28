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

module AddFile.Update exposing (update)

import AddFile.Model exposing (Model)
import AddFile.Msg exposing (Msg(..))
import AddFile.Port
import Platform.Cmd exposing (Cmd(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetVisible v ->
            ( { model | visible = v }, Cmd.none )

        ChangeIpfsHash hash ->
            ( { model | ipfsHash = hash }, Cmd.none )

        DownloadIpfs ->
            ( { model | ipfsHash = "" }, AddFile.Port.addFileByHash model.ipfsHash )

        FileRequested ->
            ( model, AddFile.Port.selectFile () )
