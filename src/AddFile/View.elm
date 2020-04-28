module AddFile.View exposing (view)

import AddFile.Model exposing (Model)
import AddFile.Msg exposing (Msg(..))
import Element exposing (Element, column, el, row, text)
import Element.Input as Input
import Palette exposing (buttonColor, fillWidth)


view : Model -> List (Element Msg)
view addFile =
    let
        block =
            if addFile.visible then
                addFileBlock addFile

            else
                Element.none
    in
    [ Input.button [ buttonColor, Element.padding 10 ] { onPress = Just <| SetVisible <| not addFile.visible, label = text "Add File" }
    , block
    ]


addFileBlock : Model -> Element Msg
addFileBlock model =
    let
        addUpload =
            Input.button [ buttonColor, Element.padding 10 ] { onPress = Just FileRequested, label = text "Select & Upload" }

        ipfsDownload =
            Input.button [ buttonColor, Element.padding 10 ] { onPress = Just DownloadIpfs, label = text "Download" }

        ipfsInput =
            Input.text []
                { onChange = ChangeIpfsHash
                , text = model.ipfsHash
                , placeholder = Just <| Input.placeholder [] <| text "Enter IPFS hash"
                , label = Input.labelRight [ Element.centerY ] <| ipfsDownload
                }

        addIpfs =
            row [ fillWidth ] [ ipfsInput ]
    in
    column [ fillWidth, Element.spacing 30 ]
        [ addUpload
        , addIpfs
        ]
