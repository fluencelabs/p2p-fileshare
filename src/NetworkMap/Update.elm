module NetworkMap.Update exposing (update)

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

import Array
import Dict exposing (Dict, get)
import Iso8601 exposing (fromTime)
import Maybe exposing (map, withDefault)
import NetworkMap.Certificates.Model as Certificates
import NetworkMap.Certificates.Update
import NetworkMap.Model exposing (Model, NodeEntry, PeerType(..))
import NetworkMap.Msg exposing (Msg(..))
import Task exposing (perform)
import Time
import Tuple exposing (first, second)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PeerAppeared peer peerType date ->
            let
                updatedPeer =
                    map (\p -> { p | date = date, appearencesNumber = p.appearencesNumber + 1 })
                        (get peer.id model.network)

                record =
                    updatedPeer
                        |> withDefault
                            { peer = peer
                            , peerType = peerType
                            , date = date
                            , appearencesNumber = 0
                            , certificates = { id = peer.id, certificates = Array.empty, showCertState = Nothing }
                            , actionsOpened = False
                            }

                peers =
                    model.network |> Dict.insert record.peer.id record
            in
            ( { model | network = peers }, Cmd.none )

        OpenActions id ->
            let
                updated =
                    model.network
                        |> Dict.update
                            id
                            (\nm -> map (\n -> { n | actionsOpened = not n.actionsOpened }) nm)
            in
            ( { model | network = updated }, Cmd.none )

        ChangePeerInput peerId ->
            ( { model | peerInput = peerId }, Cmd.none )

        AddPeerId ->
            let
                peerId =
                    model.peerInput

                cmd =
                    Time.now |> perform (\t -> PeerAppeared { id = peerId } Undefined (fromTime t))
            in
            ( { model | peerInput = "" }, cmd )

        CertMsg id certMsg ->
            let
                node =
                    model.network |> get id

                result =
                    node |> map (\n -> NetworkMap.Certificates.Update.update certMsg n.certificates)

                updated =
                    result
                        |> map
                            (\tuple -> ( { model | network = updateDict id (first tuple) model.network }, Cmd.map (CertMsg id) (second tuple) ))
            in
            updated |> withDefault ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


updateEntry : Certificates.Model -> NodeEntry -> NodeEntry
updateEntry certModel entry =
    { entry | certificates = certModel }


updateDict : String -> Certificates.Model -> Dict String NodeEntry -> Dict String NodeEntry
updateDict id model dict =
    Dict.update id (\nm -> map (updateEntry model) nm) dict
