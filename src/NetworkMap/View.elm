module NetworkMap.View exposing (view)

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
import Element.Font as Font
import Element.Input as Input
import Maybe exposing (andThen)
import NetworkMap.Model exposing (Certificate, Model, NodeEntry, PeerType(..), ShowCertState, Trust)
import NetworkMap.Msg exposing (Msg(..))
import Element exposing (Element, alignLeft, alignRight, centerX, centerY, column, el, fillPortion, padding, paddingXY, paragraph, row, text, width)
import Ions.Font as F
import Ions.Background as Background
import Ions.Border as B
import Array as A exposing (Array)
import List exposing (head, sortBy)
import Palette exposing (blockBackground, fillWidth, layoutBlock, limitLayoutWidth, shortHashRaw)
import Screen.Model as Screen
import Time
import Iso8601 exposing (fromTime)

showCertLink : Int -> Int -> String -> Bool -> Element Msg
showCertLink certIdx trustIdx id sep =
    let
        txt = (shortHashRaw 6 id)
        _ = Debug.log "idxs: " (String.fromInt certIdx ++ ":" ++ String.fromInt trustIdx)
        showCertL =
            Input.button
               []
               { onPress = Just <| ShowTrust id certIdx trustIdx, label = text (if (sep) then txt ++ " -> " else txt) }
    in
        showCertL

certViewAr : Int -> Certificate -> Maybe Int -> Element Msg
certViewAr certIdx cert showTrust =
    let
        ar = cert.chain
        all = A.indexedMap (\i -> \t ->
            if (i == A.length ar - 1) then
                showCertLink certIdx i t.issuedFor False
            else
                showCertLink certIdx i t.issuedFor True) ar
        list = A.toList all
        until = head <| sortBy (\t -> t.expiresAt) <| A.toList cert.chain
        untilIso = fromTime <| Time.millisToPosix <| Maybe.withDefault 0 <| Maybe.map .expiresAt until
        trustToShow = showTrust
                          |> andThen (\st -> A.get st ar
                          |> andThen (\t -> Just (column [] [
                            row [] [text t.issuedFor],
                            row [] [text <| String.fromInt t.expiresAt],
                            row [] [text <| String.fromInt  t.issuedAt],
                            row [] [text t.signature]
                            ])))
    in
        column []
        [ row [] <| list ++ [text <| " - until " ++ untilIso]
        , Maybe.withDefault Element.none trustToShow
        ]

actionView : String -> Array Certificate -> Maybe ShowCertState -> List (Element Msg)
actionView id certs showCertState =
    let
        addCertButton =
            Input.button
               []
               { onPress = Just <| AddCertificate id, label = text "Add Cert" }
        getCertButton =
            Input.button
                []
                { onPress = Just <| GetCertificate id, label = text "Get Cert" }
        certsView =
            A.indexedMap
                (\i -> \c ->
                    Maybe.withDefault (certViewAr i c Nothing)
                        (Maybe.andThen
                            (\scs ->
                                if (scs.certIdx == i) then
                                    Just (certViewAr i c <| Just scs.trustIdx)
                                else
                                    Just (certViewAr i c Nothing))
                        showCertState)
                )
                certs
    in [ row [ limitLayoutWidth, Background.white, centerX ]
            [ el [ alignRight, padding 10 ] <| addCertButton
            , el [ alignRight, padding 10 ] <| getCertButton
            ]
        ,  row [ limitLayoutWidth, Background.white, centerX ]
            <| A.toList certsView
        ]

addPeerView : Screen.Model -> Model -> List (Element Msg)
addPeerView screen networkModel =
    let
        peerIdInput =
            Element.el [width (fillPortion 5)] <| Input.text [ centerX, fillWidth ]
                { onChange = ChangePeerInput
                , text = networkModel.peerInput
                , placeholder = Just <| Input.placeholder [] <| text "Enter PeerId"
                , label = Input.labelHidden "Enter PeerId"
                }
        peerIdButton =
            Input.button
               [centerX, width (fillPortion 2), Font.center, B.orange, B.width1 B.AllSides, padding 10]
               { onPress = Just AddPeerId, label = text "Add Peer" }
    in
        [ row [ fillWidth ] [ peerIdInput, peerIdButton ] ]

view : Screen.Model -> Model -> Element Msg
view screen networkModel =
    if networkModel.show then
        let
            sortedEntries = List.sortBy .date (Dict.values networkModel.network)
        in
            column (layoutBlock screen ++ [ blockBackground ]) <|
                [ row [ fillWidth, F.white, F.size2, Background.gray, padding 10 ]
                    [ el [ centerX ] <| text "Network map"
                    ]
                ] ++ addPeerView screen networkModel
                    ++ List.reverse (List.map showNode sortedEntries)
    else
        Element.none

peerTypeToString : PeerType -> String
peerTypeToString pt =
    case pt of
        Relay ->
            "Relay"
        Client ->
            "Client"
        Undefined ->
            "Undefined"

showNode : NodeEntry -> Element Msg
showNode nodeEntry =
    let
        actionButton =
            Input.button
               []
               { onPress = Just <| OpenActions nodeEntry.peer.id, label = text "Actions" }
    in
        column [ fillWidth, paddingXY 0 10, B.width1 B.Bottom, B.nearBlack ]
            ([ row [ limitLayoutWidth, Background.white, centerX ]
                [ el
                      [ Font.center
                      , centerY
                      , alignLeft
                      ] <| text nodeEntry.date
                , el [ centerX, padding 10 ] <| text (String.fromInt nodeEntry.appearencesNumber)
                , el [ centerX, padding 10 ] <| text (peerTypeToString nodeEntry.peerType)
                , el [ alignRight, padding 10 ] <| text nodeEntry.peer.id
                , el [ alignRight, padding 10 ] <| actionButton
                ]
            ] ++ if (nodeEntry.actionsOpened) then (actionView nodeEntry.peer.id nodeEntry.certificates nodeEntry.showCertState) else [] )
