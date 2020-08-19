module Model exposing (Model, emptyModel)

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

import Config exposing (Config)
import Dict
import Element
import Msg exposing (Msg(..))
import NetworkMap.AvailableModules.Model
import NetworkMap.CreateService.Model exposing (initModel)
import NetworkMap.Interfaces.Model
import NetworkMap.WasmUploader.Model
import Screen.Model as Screen


type alias Model =
    { wasmUploader : NetworkMap.WasmUploader.Model.Model
    , createService : NetworkMap.CreateService.Model.Model
    , availableModules : NetworkMap.AvailableModules.Model.Model
    , interface : NetworkMap.Interfaces.Model.Model
    , screen : Screen.Model
    }


emptyModel : Config -> ( Model, Cmd Msg )
emptyModel config =
    let
        device =
            Element.classifyDevice config.windowSize

        peer =
            config.defaultPeerRelayInput.peerId
    in
    ( { wasmUploader = { id = peer, name = "", resultName = Nothing }
      , interface = { id = peer, interfaces = [], isOpenedInterfaces = Dict.empty, inputs = Dict.empty, results = Dict.empty }
      , availableModules = { id = peer, modules = [] }
      , createService = initModel peer
      , screen = { device = device, screenSize = config.windowSize }
      }
    , Cmd.none
    )
