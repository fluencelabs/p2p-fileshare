module Model exposing (Model, emptyModel)

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

import Config exposing (Config)
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


emptyModel : Maybe Config -> ( Model, Cmd Msg )
emptyModel config =
    let
        isAdmin = Maybe.withDefault False (Maybe.map (\f -> f.isAdmin) config)
        defaultInput = Maybe.map .defaultPeerRelayInput config
        (emptyConnModel, cmd) = emptyConn isAdmin defaultInput
    in
        ( { connectivity = emptyConnModel
        , addFile = emptyAddFile
        , filesList = emptyFilesList
        , networkMap = emptyNetwork
        }, Cmd.map ConnMsg cmd)
