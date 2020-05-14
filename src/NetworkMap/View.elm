module NetworkMap.View exposing (view)

import Dict
import Element.Font as Font
import NetworkMap.Model exposing (Model, NodeEntry)
import NetworkMap.Msg exposing (Msg(..))
import Element exposing (Element, alignLeft, alignRight, centerX, centerY, column, el, padding, paddingXY, row, text)
import Ions.Font as F
import Ions.Background as Background
import Ions.Border as Border
import Palette exposing (blockBackground, fillWidth, layoutBlock, limitLayoutWidth)

view : Model -> Element Msg
view networkModel =
    if networkModel.show then
        let sortedEntries = List.sortBy .date (Dict.values networkModel.network)
        in
        column (layoutBlock ++ [ blockBackground ]) <|
            [ row [ fillWidth, F.white, F.size2, Background.gray, padding 10 ]
                [ el [ centerX ] <| text "Network map"
                ]
            ]
                ++ List.reverse (List.map showNode sortedEntries)
    else
        Element.none


showNode : NodeEntry -> Element msg
showNode nodeEntry =
    column [ fillWidth, paddingXY 0 10, Border.width1 Border.Bottom, Border.nearBlack ]
            [ row [ limitLayoutWidth, Background.white, centerX ]
                [ el
                      [ Font.center
                      , centerY
                      , alignLeft
                      ] <| text nodeEntry.date
                , el [ centerX, padding 10 ] <| text (Debug.toString nodeEntry.peerType)
                , el [ alignRight, padding 10 ] <| text nodeEntry.peer.id
                ]
            ]
