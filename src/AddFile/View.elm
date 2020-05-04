module AddFile.View exposing (view)

import AddFile.Model exposing (Model)
import AddFile.Msg exposing (Msg(..))
import Element
    exposing
        ( Element
        , centerX
        , column
        , el
        , fillPortion
        , mouseOver
        , padding
        , paddingXY
        , row
        , spacing
        , text
        , width
        )
import Element.Font as Font
import Element.Input as Input
import Ions.Background as BG
import Ions.Border as B
import Ions.Color as C
import Ions.Font as F
import Palette exposing (buttonColor, fillWidth, limitLayoutWidth)


view : Model -> List (Element Msg)
view addFile =
    let
        block =
            if addFile.visible then
                addFileBlock addFile

            else
                Element.none

        addFileButton =
            Input.button
                [ BG.white
                , B.lightGreen
                , B.width2 B.AllSides
                , limitLayoutWidth
                , centerX
                , padding 10
                , Font.center
                , C.easeIn
                , mouseOver [ B.green ]
                ]
                { onPress = Just <| SetVisible <| not addFile.visible, label = text "Add File" }
    in
    [ row [ fillWidth, BG.washedGreen, paddingXY 0 20 ] [ addFileButton ]
    , block
    ]


addFileBlock : Model -> Element Msg
addFileBlock model =
    let
        addUpload =
            row [ centerX, limitLayoutWidth, BG.white ]
                [ el [ width (fillPortion 3), padding 10, F.nearBlack ] <| text "Provide a file from your computer:"
                , Input.button
                    [ centerX
                    , width (fillPortion 2)
                    , Font.center
                    , B.orange
                    , B.width1 B.AllSides
                    , padding 10
                    ]
                    { onPress = Just FileRequested, label = text "Select & Upload" }
                ]

        ipfsDownload =
            Input.button
                [ B.orange
                , B.width1 B.AllSides
                , padding 10
                , fillWidth
                , Font.center
                ]
                { onPress = Just DownloadIpfs, label = text "Download" }

        ipfsInput =
            Input.text [ width (fillPortion 4), centerX ]
                { onChange = ChangeIpfsHash
                , text = model.ipfsHash
                , placeholder = Just <| Input.placeholder [] <| text "Enter IPFS hash"
                , label = Input.labelRight [ Element.centerY, width (fillPortion 1) ] <| ipfsDownload
                }

        addIpfs =
            row [ limitLayoutWidth, centerX, BG.white, spacing 0 ] [ ipfsInput ]
    in
    column [ fillWidth, spacing 20, BG.washedGreen ]
        [ addUpload
        , addIpfs
        , el [ Element.height <| Element.px 0 ] <| Element.none
        ]
