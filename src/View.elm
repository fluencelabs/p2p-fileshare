module View exposing (view)

import Browser exposing (Document)
import Element exposing (Element, column, el, row)
import Element.Events as Events
import Element.Font as Font
import Html exposing (Html)
import Model exposing (Model)
import Msg exposing (..)
import Palette exposing (dropdownBg, fillWidth, h1, layout, link, linkColor)


view : Model -> Document Msg
view model =
    { title = title model, body = [ body model ] }


title : Model -> String
title _ =
    "Fluence p2p filesharing demo app"


body : Model -> Html Msg
body model =
    layout <| List.concat [ header, connectivity model, addFiles model ]


header : List (Element Msg)
header =
    [ row
        [ Element.centerX ]
        [ h1 "Fluence demo" ]
    , row
        [ Element.centerX ]
        [ el [ Font.italic ] <| Element.text "Fluence-powered client-to-client file sharing via IPFS" ]
    , row
        [ Element.width Element.fill ]
        [ Element.textColumn [ Element.width <| Element.fillPortion 5 ] [ Element.text "Long description" ]
        , column [ Element.width <| Element.fillPortion 1 ]
            [ link "https://fluence.network" "Whitepaper"
            , link "https://fluence.network" "Deep dive"
            ]
        ]
    ]


connectivity : Model -> List (Element Msg)
connectivity model =
    let
        conn =
            model.connectivity

        peer =
            conn.peer

        relay =
            conn.relay

        discovered =
            String.fromInt <| List.length conn.discovered

        defn t =
            el [ Element.width (Element.fillPortion 2), Font.bold ] <| Element.text t

        valn t =
            el [ Element.width (Element.fillPortion 3) ] <| Element.text t

        relayId =
            el [ Element.width (Element.fillPortion 2) ] <|
                Element.text <|
                    Maybe.withDefault "Not Connected" <|
                        Maybe.map .id relay

        relaysSelect =
            if conn.choosing then
                [ Element.below <|
                    Element.column
                        [ dropdownBg
                        , Element.spacing 10
                        , Element.paddingXY 0 10
                        , fillWidth
                        ]
                        (List.map relaySelect conn.discovered)
                , dropdownBg
                ]

            else
                []

        relaySelect r =
            Element.el [ Events.onClick (SetRelay r) ] (Element.text r.id)

        changeRelay =
            el
                ([ Element.width (Element.fillPortion 1)
                 , linkColor
                 , Events.onMouseEnter (ChoosingRelay True)
                 , Events.onMouseLeave (ChoosingRelay False)
                 ]
                    ++ relaysSelect
                )
                (Element.text "Change")
    in
    [ column [ fillWidth, Element.spacing 10 ]
        [ row [ fillWidth ] [ defn "Peer ID:", valn peer.id ]
        , row [ fillWidth ] [ defn "Discovered peers:", valn discovered ]
        , row [ fillWidth ]
            [ defn "Relay ID:"
            , relayId
            , changeRelay
            ]
        ]
    ]


addFiles : Model -> List (Element Msg)
addFiles model =
    []
