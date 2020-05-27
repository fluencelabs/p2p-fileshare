module Conn.View exposing (view)

import Conn.Model exposing (Model, Status(..))
import Conn.Msg exposing (Msg(..))
import Element exposing (Element, below, centerX, column, el, fillPortion, mouseOver, none, padding, paddingXY, row, spacing, text, width)
import Element.Events as Events
import Element.Font as Font
import Ions.Background as BG
import Ions.Font as F
import Ions.Size as S
import Palette exposing (accentButton, blockBackground, blockTitle, fillWidth, layoutBlock, letterSpacing, linkStyle, shortHash, showHash)
import Element.Input as Input

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
    inputRowWithPlaceholder  name onChange text Nothing

inputRowWithPlaceholder : String -> (String -> Msg) -> String -> Maybe (Element Msg) -> Element Msg
inputRowWithPlaceholder name onChange text placeholder =
    row [ fillWidth, centerX ]
        [ defn name
        , Input.text [ width (fillPortion 5) ]
            {
            onChange = onChange
            , text = text
            , placeholder = Maybe.map (Input.placeholder []) placeholder
            , label = Input.labelHidden name
            }
        ]

adminView : Model -> List (Element Msg)
adminView conn =
    [ row [ fillWidth, centerX, F.red ] [ text conn.errorMsg ]
    , inputRowWithPlaceholder "PRIVATE SEED" UpdateRelayPrivateKeyInput conn.relayInput.seed (Just <| text "will be generated if empty")
    , inputRow "RELAY PEER ID" UpdatePeerInput conn.relayInput.peerId
    , inputRow "RELAY HOST" UpdateRelayHostInput conn.relayInput.host
    , inputRow "RELAY PORT" UpdateRelayPortInput conn.relayInput.pport
    , row [ fillWidth, centerX ]
        [
        Input.button (accentButton ++ [ width (fillPortion 3), paddingXY 0 (S.baseRem 0.5), Font.center ] )
            {
            onPress = Just <| Connect
            , label = text "CONNECT"
            }
        , el [width (fillPortion 5)] none ]

    ]

defn : String -> Element Msg
defn t =
    el [ width (fillPortion 2), letterSpacing, F.gray ] <| Element.text t

valn : Element Msg -> Element Msg
valn t =
    el [ width (fillPortion 5) ] <| t

demoView : Model -> List (Element Msg)
demoView conn =
    let
        peer =
            conn.peer

        relay =
            conn.relay

        discovered =
            String.fromInt <| List.length conn.discovered

        relayId =
            el [ Element.width (Element.fillPortion 4), Font.alignLeft ] <|
                Maybe.withDefault (Element.el [ F.lightRed ] <| Element.text (statusToString conn.status)) <|
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

        -- change relay manually if not an admin page
        changeRelay =
            if (conn.isAdmin) then
                el [ width (fillPortion 1) ] none
            else
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
        [ row [ fillWidth, centerX ] [ defn "PEER ID", valn <| showHash peer.id ]
        , row [ fillWidth, centerX ]
            [ defn "CONNECTED RELAY ID"
            , relayId
            , changeRelay
            ]
        , row [ fillWidth, centerX ] [ defn "PEERS", valn <| Element.text discovered ]
        , el [] none
        ]

view : Model -> Element Msg
view conn =
    let
        elements =
            if (conn.isAdmin) then
                adminView conn
            else
                []
    in
        column (layoutBlock ++ [ blockBackground, spacing <| S.baseRem 0.75, F.size7 ])
            ([ blockTitle <| text "NETWORK INFO" ] ++ elements ++ demoView conn)

