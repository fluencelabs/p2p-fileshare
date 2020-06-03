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
import NetworkMap.Model exposing (Model, NodeEntry, PeerType(..))
import NetworkMap.Msg exposing (Msg(..))
import Element exposing (Element, alignLeft, alignRight, centerX, centerY, column, el, padding, paddingXY, row, text)
import Ions.Font as F
import Ions.Background as Background
import Ions.Border as Border
import Palette exposing (blockBackground, fillWidth, layoutBlock, limitLayoutWidth)
import Screen.Model as Screen

view : Screen.Model -> Model -> Element Msg
view screen networkModel =
    if networkModel.show then
        let sortedEntries = List.sortBy .date (Dict.values networkModel.network)
        in
        column (layoutBlock screen ++ [ blockBackground ]) <|
            [ row [ fillWidth, F.white, F.size2, Background.gray, padding 10 ]
                [ el [ centerX ] <| text "Network map"
                ]
            ]
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

showNode : NodeEntry -> Element msg
showNode nodeEntry =
    column [ fillWidth, paddingXY 0 10, Border.width1 Border.Bottom, Border.nearBlack ]
            [ row [ limitLayoutWidth, Background.white, centerX ]
                [ el
                      [ Font.center
                      , centerY
                      , alignLeft
                      ] <| text nodeEntry.date
                , el [ centerX, padding 10 ] <| text (String.fromInt nodeEntry.appearencesNumber)
                , el [ centerX, padding 10 ] <| text (peerTypeToString nodeEntry.peerType)
                , el [ alignRight, padding 10 ] <| text nodeEntry.peer.id
                ]
            ]
