module AddFile.View exposing (view)

{-| Copyright 2020 Fluence Labs Limited

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

import AddFile.Model exposing (Model)
import AddFile.Msg exposing (Msg(..))
import Element exposing (Element, centerX, column, el, fillPortion, padding, paddingXY, paragraph, pointer, row, spacing, text, width)
import Element.Border exposing (dotted)
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Ions.Background as BG
import Ions.Border as B
import Ions.Font as F
import Ions.Size as S
import Palette exposing (accentButton, blockTitle, fillWidth, layoutBlock)
import Screen.Model as Screen exposing (isMedium)


view : Screen.Model -> Model -> Element Msg
view screen addFile =
    let
        block =
            if addFile.visible then
                addFileBlock screen addFile

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
        [ row (layoutBlock screen) [ addFileButton ]
        , block
        ]


addFileBlock : Screen.Model -> Model -> Element Msg
addFileBlock screen model =
    let
        rowAttrs =
            [ centerX, fillWidth, BG.white, spacing 10, paddingXY 0 10 ]

        inputAttrs =
            [ centerX, width (fillPortion 2), Font.center, B.orange, B.width1 B.AllSides, padding 10 ]

        emptyColumn =
            Element.el [ width <| fillPortion 4 ] Element.none

        intro =
            el [ paddingXY 0 10, F.size5 ] <| paragraph [] [ text "Add file from your device or enter IPFS hash" ]

        or =
            el [ paddingXY 0 10, F.size5 ] <| text "OR"

        addDownload =
            el [ width (fillPortion 5) ] <| el [ padding 10, fillWidth, F.gray, B.width1 B.AllSides, dotted, onClick FileRequested, pointer ] <| text "Choose file from your device"

        addInput =
            Input.button
                inputAttrs
                { onPress = Just FileRequested, label = text "Browse file" }

        ipfsDownload =
            Input.button
                inputAttrs
                { onPress = Just DownloadIpfs, label = text "Download" }

        ipfsInput =
            Element.el [ width (fillPortion 5) ] <|
                Input.text [ centerX, fillWidth ]
                    { onChange = ChangeIpfsHash
                    , text = model.ipfsHash
                    , placeholder = Just <| Input.placeholder [] <| text "Enter IPFS hash"
                    , label = Input.labelHidden "Enter IPFS hash"
                    }
    in
    if isMedium screen then
        column (layoutBlock screen ++ [ B.width1 B.AllSides, B.radius2, B.blackAlpha 100 ])
            [ blockTitle <| text "ADD FILE"
            , intro
            , row rowAttrs [ addDownload ]
            , row rowAttrs [ addInput ]
            , or
            , row rowAttrs [ ipfsInput ]
            , row rowAttrs [ ipfsDownload ]
            , el [ Element.height <| Element.px 0 ] <| Element.none
            ]

    else
        column (layoutBlock screen ++ [ B.width1 B.AllSides, B.radius2, B.blackAlpha 100 ])
            [ blockTitle <| text "ADD FILE"
            , intro
            , row rowAttrs [ addDownload, addInput, emptyColumn ]
            , or
            , row rowAttrs [ ipfsInput, ipfsDownload, emptyColumn ]
            , el [ Element.height <| Element.px 0 ] <| Element.none
            ]
