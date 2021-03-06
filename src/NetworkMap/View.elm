module NetworkMap.View exposing (view)

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

import Dict
import Element exposing (Element, alignLeft, alignRight, centerX, centerY, column, el, fillPortion, padding, paddingXY, row, text, width)
import Element.Font as Font
import Element.Input as Input
import Element.Lazy exposing (lazy)
import Ions.Background as Background
import Ions.Border as B
import Ions.Font as F
import NetworkMap.Certificates.View
import NetworkMap.Interfaces.View
import NetworkMap.Model exposing (Model, NodeEntry, PeerType(..))
import NetworkMap.Msg exposing (Msg(..))
import NetworkMap.Services.View
import Palette exposing (blockBackground, fillWidth, layoutBlock, limitLayoutWidth)
import Screen.Model as Screen


addPeerView : Screen.Model -> Model -> List (Element Msg)
addPeerView screen networkModel =
    let
        peerIdInput =
            Element.el [ width (fillPortion 5) ] <|
                Input.text [ centerX, fillWidth ]
                    { onChange = ChangePeerInput
                    , text = networkModel.peerInput
                    , placeholder = Just <| Input.placeholder [] <| text "Enter PeerId"
                    , label = Input.labelHidden "Enter PeerId"
                    }

        peerIdButton =
            Input.button
                [ centerX, width (fillPortion 2), Font.center, B.orange, B.width1 B.AllSides, padding 10 ]
                { onPress = Just AddPeerId, label = text "Add Peer" }
    in
    [ row [ fillWidth ] [ peerIdInput, peerIdButton ] ]


view : Screen.Model -> Model -> Element Msg
view screen networkModel =
    let
        sortedEntries =
            List.sortBy .idx (Dict.values networkModel.network)
    in
    column (layoutBlock screen ++ [ blockBackground ]) <|
        [ row [ fillWidth, F.white, F.size2, Background.gray, padding 10 ]
            [ el [ centerX ] <| text "Network map"
            ]
        ]
            ++ addPeerView screen networkModel
            ++ List.map (showNode screen) sortedEntries


peerTypeToString : PeerType -> String
peerTypeToString pt =
    case pt of
        Relay ->
            "Relay"

        Client ->
            "Client"

        Undefined ->
            "Undefined"


showNode : Screen.Model -> NodeEntry -> Element Msg
showNode screen nodeEntry =
    let
        actionButton =
            Input.button
                [ padding 10, Background.blackAlpha 60 ]
                { onPress = Just <| OpenActions nodeEntry.peer.id, label = text "Actions" }

        background =
            if nodeEntry.actionsOpened then
                Background.washedGreen

            else
                Background.white
    in
    column [ fillWidth, paddingXY 0 10, B.width1 B.Bottom, B.nearBlack ]
        ([ row [ limitLayoutWidth, background, centerX ]
            [ el
                [ Font.center
                , centerY
                , alignLeft
                ]
              <|
                text nodeEntry.date
            , el [ centerX, padding 10 ] <| text (String.fromInt nodeEntry.appearencesNumber)
            , el [ centerX, padding 10 ] <| text (peerTypeToString nodeEntry.peerType)
            , el [ alignRight, padding 10 ] <| text nodeEntry.peer.id
            , el [ alignRight, padding 10 ] <| actionButton
            ]
         ]
            ++ (if nodeEntry.actionsOpened then
                    [ certificateOptions nodeEntry
                    , interfaceOptions nodeEntry
                    , servicesOptions screen nodeEntry
                    , services screen nodeEntry
                    , certificates screen nodeEntry
                    , interfaces screen nodeEntry
                    ]

                else
                    [ Element.none ]
               )
        )


interfaces : Screen.Model -> NodeEntry -> Element Msg
interfaces screen node =
    liftView .interfaces (InterfaceMsg node.peer.id) (NetworkMap.Interfaces.View.view screen) <| node


services : Screen.Model -> NodeEntry -> Element Msg
services screen node =
    liftView .services (ServicesMsg node.peer.id) (NetworkMap.Services.View.view screen) <| node


interfaceOptions : NodeEntry -> Element Msg
interfaceOptions node =
    liftView .interfaces (InterfaceMsg node.peer.id) NetworkMap.Interfaces.View.optionsView <| node


servicesOptions : Screen.Model -> NodeEntry -> Element Msg
servicesOptions screen node =
    liftView .services (ServicesMsg node.peer.id) (NetworkMap.Services.View.optionsView screen) <| node


certificates : Screen.Model -> NodeEntry -> Element Msg
certificates screen node =
    liftView .certificates (CertMsg node.peer.id) (NetworkMap.Certificates.View.view screen) <| node


certificateOptions : NodeEntry -> Element Msg
certificateOptions node =
    liftView .certificates (CertMsg node.peer.id) NetworkMap.Certificates.View.optionsView <| node


liftView :
    (NodeEntry -> model)
    -> (msg -> Msg)
    -> (model -> Element msg)
    -> (NodeEntry -> Element Msg)
liftView getModel liftMsg subView =
    \model ->
        let
            subModel =
                getModel model

            res =
                lazy subView <| subModel
        in
        Element.map liftMsg res
