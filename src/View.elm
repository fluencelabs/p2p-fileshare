module View exposing (view)

import AddFile.View
import Browser exposing (Document)
import Conn.View
import Element
    exposing
        ( Element
        , column
        , el
        , height
        , paragraph
        , row
        , spacing
        , text
        , textColumn
        )
import Element.Font as Font
import Element.Lazy exposing (lazy)
import FilesList.View
import Html exposing (Html)
import Ions.Font as F
import Ions.Size as S
import Model exposing (Model)
import Msg exposing (..)
import NetworkMap.View
import Palette exposing (fillWidth, h1, layout, layoutBlock, link, pSpacing)


view : Model -> Document Msg
view model =
    { title = title model, body = [ body model ] }


title : Model -> String
title _ =
    "Fluence p2p filesharing demo app"


body : Model -> Html Msg
body model =
    layout <| List.concat [ header, [ connectivity model, addFile model, filesList model, networkMap model ] ]


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
    [ column (layoutBlock ++ [ spacing (S.baseRem 1.125) ])
        [ row
            [ fillWidth ]
            [ h1 "P2P Application Fluence Demo" ]
        , row
            [ fillWidth ]
            [ paragraph [ Font.italic, F.gray, pSpacing ] <|
                [ text "P2P file-sharing application over IPFS via Fluence relay" ]
            ]
        , row
            [ fillWidth ]
            [ textColumn
                [ fillWidth, spacing <| S.baseRem 1 ]
                [ paragraph [ pSpacing ] [ text "This is a peer-to-peer file-sharing demo, that uses Fluence protocol to advertise and discover files, and IPFS to upload/download." ]
                , paragraph [ pSpacing ] [ text "First, choose your local file and make it discoverable via Fluence network. Other peers may discover your device as a holder of the file and ask it to provide the file to a publicly accessible IPFS node. Your device will upload the file to the IPFS node and then share its multiaddress with the requesting peer." ]
                , row [ spacing (S.baseRem 1) ] [ link "https://fluence.network" "More about Fluence", link "https://fluence.network" "Documentation" ]
                ]
            ]
        , el [ height <| Element.px <| S.baseRem 0.5 ] Element.none
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

networkMap : Model -> Element Msg
networkMap model =
    liftView .networkMap NetworkMapMsg NetworkMap.View.view <| model
