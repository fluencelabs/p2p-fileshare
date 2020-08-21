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
import NetworkMap.Interfaces.Model as Interfaces
import NetworkMap.Interfaces.Msg as InterfaceMsg
import NetworkMap.Interfaces.Update
import NetworkMap.Model exposing (Model, NodeEntry, PeerType(..))
import NetworkMap.Msg exposing (Msg(..))
import NetworkMap.Services.Model as Services
import NetworkMap.Services.Msg as ServicesMsg
import NetworkMap.Services.Update
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
                            , certificates = { id = peer.id, certificates = Array.empty, showCertState = Nothing, trusts = Dict.empty }
                            , interfaces = { id = peer.id, interfaces = [], isOpenedInterfaces = Dict.empty, inputs = Dict.empty, results = Dict.empty }
                            , services = Services.initModel peer.id
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

        InterfaceMsg id intMsg ->
            liftInterfaceMsg model id intMsg

        ServicesMsg id sMsg ->
            liftServicesMsg model id sMsg

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


updateAndLiftMsg :
    Model
    -> String
    -> msg
    -> (NodeEntry -> model)
    -> (msg -> model -> ( model, Cmd msg ))
    -> (String -> msg -> Msg)
    -> (String -> model -> Dict String NodeEntry -> Dict String NodeEntry)
    -> ( Model, Cmd Msg )
updateAndLiftMsg model id msg getModel updateModel liftMsgF updateNodeEntry =
    let
        node =
            model.network |> get id

        result =
            node |> map (\n -> updateModel msg (getModel n))

        updated =
            result
                |> map
                    (\tuple -> ( { model | network = updateNodeEntry id (first tuple) model.network }, Cmd.map (liftMsgF id) (second tuple) ))
    in
    updated |> withDefault ( model, Cmd.none )


liftCertMsg : Model -> String -> CertificatesMsg.Msg -> ( Model, Cmd Msg )
liftCertMsg model id msg =
    updateAndLiftMsg model id msg .certificates NetworkMap.Certificates.Update.update CertMsg updateDict


liftServicesMsg : Model -> String -> ServicesMsg.Msg -> ( Model, Cmd Msg )
liftServicesMsg model id msg =
    updateAndLiftMsg model id msg .services NetworkMap.Services.Update.update ServicesMsg updateServices


liftInterfaceMsg : Model -> String -> InterfaceMsg.Msg -> ( Model, Cmd Msg )
liftInterfaceMsg model id msg =
    updateAndLiftMsg model id msg .interfaces NetworkMap.Interfaces.Update.update InterfaceMsg updateIDict


updateIEntry : Interfaces.Model -> NodeEntry -> NodeEntry
updateIEntry interfaces entry =
    { entry | interfaces = interfaces }


updateServicesEntry : Services.Model -> NodeEntry -> NodeEntry
updateServicesEntry services entry =
    { entry | services = services }


updateIDict : String -> Interfaces.Model -> Dict String NodeEntry -> Dict String NodeEntry
updateIDict id model dict =
    Dict.update id (\nm -> map (updateIEntry model) nm) dict


updateServices : String -> Services.Model -> Dict String NodeEntry -> Dict String NodeEntry
updateServices id model dict =
    Dict.update id (\nm -> map (updateServicesEntry model) nm) dict


updateEntry : Certificates.Model -> NodeEntry -> NodeEntry
updateEntry certModel entry =
    { entry | certificates = certModel }


updateDict : String -> Certificates.Model -> Dict String NodeEntry -> Dict String NodeEntry
updateDict id model dict =
    Dict.update id (\nm -> map (updateEntry model) nm) dict
