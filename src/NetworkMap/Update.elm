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
import NetworkMap.Certificates.Msg as CertificatesMsg
import NetworkMap.Certificates.Update
import NetworkMap.Model exposing (Model, NodeEntry, PeerType(..))
import NetworkMap.Msg exposing (Msg(..))
import Task exposing (perform)
import Time
import Tuple exposing (first, second)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PeerAppeared peer peerType date opened ->
            let
                updatedPeer =
                    map (\p -> { p | date = date, appearencesNumber = p.appearencesNumber + 1 })
                        (get peer.id model.network)

                record =
                    updatedPeer
                        |> withDefault
                            { peer = peer
                            , idx = Dict.size model.network
                            , peerType = peerType
                            , date = date
                            , appearencesNumber = 0
                            , certificates = { id = peer.id, certificates = Array.empty, showCertState = Nothing }
                            , actionsOpened = opened
                            }

                peers =
                    model.network |> Dict.insert record.peer.id record
            in
            ( { model | network = peers }, Cmd.none )

        OpenActions id ->
            let
                updated =
                    model.network
                        |> Dict.map (openOnlyOne id)
            in
            ( { model | network = updated }, Cmd.none )

        ChangePeerInput peerId ->
            ( { model | peerInput = peerId }, Cmd.none )

        AddPeerId ->
            let
                peerId =
                    model.peerInput

                cmd =
                    Time.now |> perform (\t -> PeerAppeared { id = peerId } Undefined (fromTime t) True)
            in
            ( { model | peerInput = "" }, cmd )

        CertMsg id certMsg ->
            case certMsg of
                -- this message is from child to change focus on this level
                CertificatesMsg.ChangeFocus idFor ->
                    updateFocus model idFor

                _ ->
                    liftCertMsg model id certMsg

        NoOp ->
            ( model, Cmd.none )



-- change 'actionsOpened' to true, only if 'currentId' equals 'idToOpen'


openOnlyOne : String -> String -> NodeEntry -> NodeEntry
openOnlyOne idToOpen currentId nodeEntry =
    let
        opened =
            if currentId == idToOpen then
                True

            else
                False
    in
    { nodeEntry | actionsOpened = opened }



-- should be moved with 'Certificates' model if necessary


updateFocus : Model -> String -> ( Model, Cmd Msg )
updateFocus model id =
    let
        updated =
            model.network |> Dict.map (openOnlyOne id)

        cmd =
            if Dict.member id model.network then
                Cmd.none

            else
                Time.now |> perform (\t -> PeerAppeared { id = id } Undefined (fromTime t) True)
    in
    ( { model | network = updated }, cmd )


liftCertMsg : Model -> String -> CertificatesMsg.Msg -> ( Model, Cmd Msg )
liftCertMsg model id msg =
    let
        node =
            model.network |> get id

        result =
            node |> map (\n -> NetworkMap.Certificates.Update.update msg n.certificates)

        updated =
            result
                |> map
                    (\tuple -> ( { model | network = updateDict id (first tuple) model.network }, Cmd.map (CertMsg id) (second tuple) ))
    in
    updated |> withDefault ( model, Cmd.none )


updateEntry : Certificates.Model -> NodeEntry -> NodeEntry
updateEntry certModel entry =
    { entry | certificates = certModel }


updateDict : String -> Certificates.Model -> Dict String NodeEntry -> Dict String NodeEntry
updateDict id model dict =
    Dict.update id (\nm -> map (updateEntry model) nm) dict
