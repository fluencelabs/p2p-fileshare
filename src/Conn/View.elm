module Conn.View exposing (view)

import Conn.Model exposing (Model)
import Conn.Msg exposing (Msg(..))
import Element exposing (Element, below, centerX, column, el, fillPortion, height, mouseOver, none, padding, paddingXY, px, row, spacing, text, width)
import Element.Events as Events
import Element.Font as Font
import Ions.Background as BG
import Ions.Border as B
import Ions.Color as C
import Ions.Font as F
import Ions.Size as S
import Palette exposing (blockBackground, blockTitle, fillWidth, layoutBlock, letterSpacing, linkStyle, shortHash, showHash)


view : Model -> Element Msg
view conn =
    let
        peer =
            conn.peer

        relay =
            conn.relay

        discovered =
            String.fromInt <| List.length conn.discovered

        defn t =
            el [ width (fillPortion 2), letterSpacing, F.gray ] <| Element.text t

        valn t =
            el [ width (fillPortion 5) ] <| t

        relayId =
            el [ Element.width (Element.fillPortion 4) ] <|
                Maybe.withDefault (Element.el [ F.lightRed ] <| Element.text "Not Connected") <|
                    Maybe.map (.peer >> .id >> showHash) relay

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
    column (layoutBlock ++ [ blockBackground, spacing <| S.baseRem 0.75, F.size7 ])
        [ blockTitle <| text "NETWORK INFO"
        , row [ fillWidth, centerX ] [ defn "PEER ID", valn <| showHash peer.id ]
        , row [ fillWidth, centerX ]
            [ defn "CONNECTED RELAY ID"
            , relayId
            , changeRelay
            ]
        , row [ fillWidth, centerX ] [ defn "PEERS", valn <| Element.text discovered ]
        , el [] none
        ]
