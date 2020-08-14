module NetworkMap.Msg exposing (Msg(..))

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

import NetworkMap.AvailableModules.Msg
import NetworkMap.Certificates.Msg
import NetworkMap.CreateService.Msg
import NetworkMap.Interfaces.Msg
import NetworkMap.Model exposing (Peer, PeerType)
import NetworkMap.WasmUploader.Msg


type Msg
    = PeerAppeared Peer PeerType String Bool
    | OpenActions String
    | InterfaceMsg String NetworkMap.Interfaces.Msg.Msg
    | WasmUploaderMsg String NetworkMap.WasmUploader.Msg.Msg
    | ModulesMsg String NetworkMap.AvailableModules.Msg.Msg
    | CertMsg String NetworkMap.Certificates.Msg.Msg
    | CreateServiceMsg String NetworkMap.CreateService.Msg.Msg
    | ChangePeerInput String
    | AddPeerId
    | NoOp
