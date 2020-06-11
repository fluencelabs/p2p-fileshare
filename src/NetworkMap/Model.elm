module NetworkMap.Model exposing (..)

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

import Dict exposing (Dict)
import NetworkMap.Certificates.Model as Certificates


type PeerType
    = Relay
    | Client
    | Undefined


type alias Peer =
    { id : String }


type alias NodeEntry =
    { peer : Peer
    , peerType : PeerType
    , date : String
    , appearencesNumber : Int
    , certificates : Certificates.Model
    , actionsOpened : Bool
    }


type alias Model =
    { network : Dict String NodeEntry
    , peerInput : String
    , show : Bool
    }


emptyNetwork : Bool -> Model
emptyNetwork isAdmin =
    { network = Dict.empty
    , peerInput = ""
    , show = isAdmin
    }
