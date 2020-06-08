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

import Array
import Dict
import Iso8601 exposing (fromTime)
import NetworkMap.Model exposing (Model, PeerType(..))
import NetworkMap.Msg exposing (Msg(..))
import NetworkMap.Port as Port
import Task exposing (perform)
import Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PeerAppeared peer peerType date ->
            let
                updatedPeer = Maybe.map (\p -> { p | date = date, appearencesNumber = p.appearencesNumber + 1 })
                    (Dict.get peer.id model.network)

                record =
                    Maybe.withDefault
                    { peer = peer
                    , peerType = peerType
                    , date = date
                    , appearencesNumber = 0
                    , certificates = Array.empty
                    , actionsOpened = False
                    , showCertState = Nothing
                    }
                    updatedPeer
                peers = Dict.insert record.peer.id record model.network
            in
                ( { model | network = peers }, Cmd.none )
        CertificateAdded id certs ->
            let
                updated = Dict.update
                    id
                    (\nm -> Maybe.map (\n -> { n | certificates = Array.append n.certificates certs }) nm)
                    model.network
            in
                ( { model | network = updated }, Cmd.none )
        OpenActions id ->
            let
                updated = Dict.update
                    id
                    (\nm -> Maybe.map (\n -> { n | actionsOpened = not n.actionsOpened }) nm)
                    model.network
            in
                ( { model | network = updated }, Cmd.none )
        ShowTrust id certIdx trustIdx ->
            let
                updated = Dict.update
                    id
                    (\nm -> Maybe.map (\n -> { n | showCertState = Just { certIdx = certIdx, trustIdx = trustIdx} }) nm)
                    model.network
            in
                ( { model | network = updated }, Cmd.none )
        AddCertificate id ->
            ( model, Port.networkMapRequest { command = "issue", id = Just id } )
        GetCertificate id ->
            ( model, Port.networkMapRequest { command = "get_cert", id = Just id } )
        ChangePeerInput peerId ->
            ( { model | peerInput = peerId }, Cmd.none )
        AddPeerId ->
            let
                peerId = model.peerInput
                cmd = Time.now |> perform (\t -> (PeerAppeared {id = peerId} Undefined (fromTime t)))
            in
                ( { model | peerInput = "" }, cmd)
        NoOp ->
            ( model, Cmd.none )
