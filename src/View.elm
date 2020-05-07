module View exposing (view)

import AddFile.View
import Browser exposing (Document)
import Conn.View
import Element
    exposing
        ( Element
        , alignRight
        , alignTop
        , centerX
        , column
        , el
        , fillPortion
        , padding
        , paragraph
        , row
        , spacing
        , text
        , textColumn
        , width
        )
import Element.Font as Font
import Element.Lazy exposing (lazy)
import FilesList.View
import Html exposing (Html)
import Ions.Background as BG
import Ions.Border as B
import Ions.Font as F
import Model exposing (Model)
import Msg exposing (..)
import Palette exposing (fillWidth, h1, layout, limitLayoutWidth, link, linkColor)


view : Model -> Document Msg
view model =
    { title = title model, body = [ body model ] }


title : Model -> String
title _ =
    "Fluence p2p filesharing demo app"


body : Model -> Html Msg
body model =
    layout <| List.concat [ header, [ connectivity model, addFile model, filesList model ] ]


liftView :
    (Model -> model)
    -> (msg -> Msg)
    -> (model -> Element msg)
    -> (Model -> Element Msg)
liftView getModel liftMsg subView =
    \model ->
        let
            subModel =
                getModel model

            res =
                lazy subView <| subModel
        in
        Element.map liftMsg res


longDescriptionText =
    "Files are served via IPFS protocol, but actual file uploading is done lazily. "
        ++ "First, you upload your file into browser and make it discoverable via Fluence network. "
        ++ "Then your peers may discover your device as a holder of the file and ask it to provide the file to a publicly accessible IPFS node. "
        ++ "The device uploads the file and then replies with an IPFS multiaddress of the node holding the file."


header : List (Element Msg)
header =
    [ row
        [ fillWidth, B.nearBlack, B.width1 B.Bottom, padding 20 ]
        [ h1 "Fluence demo" ]
    , row
        [ fillWidth, BG.nearWhite, padding 20 ]
        [ el [ Font.italic, centerX ] <|
            text "Fluence-powered client-to-client file sharing via IPFS"
        ]
    , row
        [ centerX, limitLayoutWidth, padding 20 ]
        [ textColumn [ width <| fillPortion 5 ] [ paragraph [] [ text longDescriptionText ] ]
        , column [ width <| fillPortion 1, spacing 5, Element.alignTop ]
            [ el [ alignRight, alignTop ] <| link "https://fluence.network" "Whitepaper"
            , el [ alignRight, alignTop ] <| link "https://fluence.network" "Deep dive"
            ]
        ]
    ]


connectivity : Model -> Element Msg
connectivity model =
    liftView .connectivity ConnMsg Conn.View.view <| model


addFile : Model -> Element Msg
addFile model =
    liftView .addFile AddFileMsg AddFile.View.view <| model


filesList : Model -> Element Msg
filesList model =
    liftView .filesList FilesListMsg FilesList.View.view <| model
