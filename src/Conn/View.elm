module Conn.View exposing (view)

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

import Conn.Model exposing (Model, Status(..))
import Conn.Msg exposing (Msg(..))
import Conn.Relay exposing (Peer)
import Element exposing (DeviceClass, Element, below, centerX, column, el, fillPortion, mouseOver, none, padding, paddingXY, row, spacing, text, width)
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Ions.Background as BG
import Ions.Font as F
import Ions.Size as S
import Palette exposing (accentButton, blockBackground, blockTitle, fillWidth, layoutBlock, letterSpacing, linkStyle, mediumHash, shortHash, showHash)
import Screen.Model as Screen exposing (isMedium, isNarrow)


statusToString : Status -> String
statusToString status =
    case status of
        NotConnected ->
            "Not Connected"

        Connected ->
            "Connected"

        Connecting ->
            "Connecting..."


inputRow : String -> (String -> Msg) -> String -> Element Msg
inputRow name onChange text =
    inputRowWithPlaceholder name onChange text Nothing


inputRowWithPlaceholder : String -> (String -> Msg) -> String -> Maybe (Element Msg) -> Element Msg
inputRowWithPlaceholder name onChange text placeholder =
    row [ fillWidth, centerX ]
        [ defn name
        , Input.text [ width (fillPortion 5) ]
            { onChange = onChange
            , text = text
            , placeholder = Maybe.map (Input.placeholder []) placeholder
            , label = Input.labelHidden name
            }
        ]


adminView : Model -> List (Element Msg)
adminView conn =
    [ row [ fillWidth, centerX, F.red ] [ text conn.errorMsg ]
    , inputRowWithPlaceholder "PRIVATE SEED" UpdateRelayPrivateKeyInput conn.relayInput.privateKey (Just <| text "will be generated if empty")
    , inputRow "RELAY PEER ID" UpdatePeerInput conn.relayInput.peerId
    , inputRow "RELAY HOST" UpdateRelayHostInput conn.relayInput.host
    , inputRow "RELAY PORT" UpdateRelayPortInput conn.relayInput.pport
    , row [ fillWidth, centerX ]
        [ Input.button (accentButton ++ [ width (fillPortion 3), paddingXY 0 (S.baseRem 0.5), Font.center ])
            { onPress = Just <| Connect
            , label = text "CONNECT"
            }
        , el [ width (fillPortion 5) ] none
        ]
    ]


defn : String -> Element Msg
defn t =
    el [ width (fillPortion 2), letterSpacing, F.gray ] <| Element.text t


valn : Element Msg -> Element Msg
valn t =
    el [ width (fillPortion 5) ] <| t


demoView : Screen.Model -> Model -> List (Element Msg)
demoView screen conn =
    let
        peer =
            conn.peer

        relay =
            conn.relay

        discovered =
            String.fromInt <| List.length conn.discovered

        isMediumSize =
            isMedium screen

        isNarrowSize =
            isNarrow screen

        relayId =
            el [ Element.width (Element.fillPortion 4), Font.alignLeft ] <|
                Maybe.withDefault (Element.el [ F.lightRed ] <| Element.text (statusToString conn.status)) <|
                    Maybe.map
                        (.peer
                            >> .id
                            >> (if isNarrowSize then
                                    mediumHash

                                else
                                    showHash
                               )
                        )
                        relay

        relaysSelect =
            if conn.choosing then
                [ below <|
                    column
                        [ BG.washedYellow
                        , spacing <| S.baseRem 0.5
                        , fillWidth
                        ]
                        (List.map relaySelect conn.discovered)
                , BG.lightestBlue
                ]

            else
                []

        relaySelect r =
            Element.el
                [ Events.onClick (SetRelay r)
                , mouseOver [ BG.washedBlue ]
                , paddingXY 7 10
                , fillWidth
                , Element.pointer
                ]
                (shortHash r.peer.id)

        -- change relay manually if not an admin page
        changeRelay =
            el
                (linkStyle
                    ++ [ width (fillPortion 1)
                       , padding 5
                       , Events.onMouseEnter (ChoosingRelay True)
                       , Events.onMouseLeave (ChoosingRelay False)
                       , Element.pointer
                       ]
                    ++ relaysSelect
                )
                (Element.text "Change")
    in
    if isMediumSize then
        narrowView isNarrowSize peer relayId changeRelay discovered

    else
        wideView peer relayId changeRelay discovered


wideView : Peer -> Element Msg -> Element Msg -> String -> List (Element Msg)
wideView peer relayId changeRelay discovered =
    [ row [ fillWidth, centerX ] [ defn "PEER ID", valn <| showHash peer.id ]
    , row [ fillWidth, centerX ]
        [ defn "CONNECTED RELAY ID"
        , relayId
        , changeRelay
        ]
    , row [ fillWidth, centerX ] [ defn "PEERS", valn <| Element.text discovered ]
    , el [] none
    ]


narrowView : Bool -> Peer -> Element Msg -> Element Msg -> String -> List (Element Msg)
narrowView isPhoneSize peer relayId changeRelay discovered =
    [ row [ fillWidth, centerX ] [ defn "PEER ID" ]
    , row [ fillWidth, centerX ]
        [ valn <|
            (if isPhoneSize then
                mediumHash

             else
                showHash
            )
                peer.id
        ]
    , row [ fillWidth, centerX ] [ defn "CONNECTED RELAY ID" ]
    , row [ fillWidth, centerX ] [ relayId ]
    , row [ fillWidth, centerX ] [ changeRelay ]
    , row [ fillWidth, centerX ] [ defn "PEERS" ]
    , row [ fillWidth, centerX ] [ valn <| Element.text discovered ]
    , el [] none
    ]


view : Screen.Model -> Model -> Element Msg
view screen conn =
    let
        elements =
            if conn.isAdmin then
                adminView conn

            else
                []
    in
    column (layoutBlock screen ++ [ blockBackground, spacing <| S.baseRem 0.75, F.size7 ])
        ([ blockTitle <| text "NETWORK INFO" ] ++ elements ++ demoView screen conn)
