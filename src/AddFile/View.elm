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
import Ions.Size as S
import Palette exposing (accentButton, blockTitle, fillWidth, layoutBlock)


view : Model -> Element Msg
view addFile =
    let
        block =
            if addFile.visible then
                addFileBlock addFile

            else
                Element.none

        addFileButton =
            Input.button
                (accentButton
                    ++ [ paddingXY (S.baseRem 3) (S.baseRem 0.5)
                       , Font.center
                       ]
                )
                { onPress = Just <| SetVisible <| not addFile.visible, label = text "Add File +" }
    in
    column [ fillWidth ]
        [ row layoutBlock [ addFileButton ]
        , block
        ]


addFileBlock : Model -> Element Msg
addFileBlock model =
    let
        addUpload =
            row [ centerX, fillWidth, BG.white ]
                [ el [ width (fillPortion 3), padding 10, F.nearBlack ] <| text "Choose file from your device"
                , Input.button
                    [ centerX
                    , width (fillPortion 2)
                    , Font.center
                    , B.orange
                    , B.width1 B.AllSides
                    , padding 10
                    ]
                    { onPress = Just FileRequested, label = text "Browse file" }
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
            row [ fillWidth, centerX, BG.white, spacing 0 ] [ ipfsInput ]
    in
    column (layoutBlock ++ [ B.width1 B.AllSides, B.radius2, B.blackAlpha 100, spacing 20, F.size7 ])
        [ blockTitle <| text "ADD FILE"
        , addUpload
        , addIpfs
        , el [ Element.height <| Element.px 0 ] <| Element.none
        ]
