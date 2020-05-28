module NetworkMap.Update exposing (update)

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

import Dict
import NetworkMap.Model exposing (Model)
import NetworkMap.Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PeerAppeared peer peerType date ->
            let
                entry =
                    { peer = peer
                    , peerType = peerType
                    , date = date
                    }
                peers = Dict.insert entry.peer.id entry model.network
            in
                ( { model | network = peers }, Cmd.none )
        ShowHide ->
            ( { model | show = not model.show }, Cmd.none )
        NoOp ->
            ( model, Cmd.none )
