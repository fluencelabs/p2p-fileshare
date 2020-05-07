module Conn.View exposing (view)

import Conn.Model exposing (Model)
import Conn.Msg exposing (Msg(..))
import Element exposing (Element, below, centerX, column, el, fillPortion, mouseOver, padding, paddingXY, row, spacing, width)
import Element.Events as Events
import Element.Font as Font
import Ions.Background as BG
import Ions.Border as B
import Ions.Color as C
import Ions.Font as F
import Palette exposing (dropdownBg, fillWidth, h1, layout, limitLayoutWidth, link, linkColor, shortHash)


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
            el [ width (fillPortion 2), padding 7, Font.family [ Font.monospace ] ] <| Element.text t

        valn t =
            el [ width (fillPortion 3), padding 7 ] <| t

        relayId =
            el [ Element.width (Element.fillPortion 2), padding 7 ] <|
                Maybe.withDefault (Element.el [ F.lightRed ] <| Element.text "Not Connected") <|
                    Maybe.map (.peer >> .id >> shortHash) relay

        relaysSelect =
            if conn.choosing then
                [ below <|
                    column
                        [ BG.washedYellow
                        , spacing 10
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
                ([ width (fillPortion 1)
                 , BG.lightBlue
                 , B.width1 B.AllSides
                 , B.blue
                 , C.easeIn
                 , padding 5
                 , Events.onMouseEnter (ChoosingRelay True)
                 , Events.onMouseLeave (ChoosingRelay False)
                 , Element.pointer
                 ]
                    ++ relaysSelect
                )
                (Element.text "Change")
    in
    column [ fillWidth, BG.lightYellow, F.nearBlack, spacing 3, paddingXY 0 5 ]
        [ row [ limitLayoutWidth, centerX, BG.white ] [ defn "Peer ID:", valn <| shortHash peer.id ]
        , row [ limitLayoutWidth, centerX, BG.white ] [ defn "Discovered peers:", valn <| Element.text discovered ]
        , row [ limitLayoutWidth, centerX, BG.white ]
            [ defn "Relay ID:"
            , relayId
            , changeRelay
            ]
        ]
