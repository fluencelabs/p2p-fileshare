module FilesList.View exposing (view)

import Base64.Encode as Encode
import Bytes exposing (Bytes)
import Element exposing (Element, column, el, row, text)
import Element.Input as Input
import FilesList.Model exposing (FileEntry, Model, Status(..))
import FilesList.Msg exposing (Msg(..))
import Palette exposing (buttonColor, fillWidth, shortHash)


view : Model -> List (Element Msg)
view { files } =
    let
        filesList =
            files |> List.map showFile
    in
    filesList


showFilePreview : Maybe Bytes -> String -> Element Msg
showFilePreview maybeBytes imageType =
    let
        imgPreviewSrc =
            case maybeBytes of
                Just bytes ->
                    Just <| "data:image/" ++ imageType ++ ";base64," ++ Encode.encode (Encode.bytes bytes)

                Nothing ->
                    Nothing
    in
    case imgPreviewSrc of
        Just src ->
            Element.image [ Element.width <| Element.px 30, Element.height <| Element.px 30 ] { description = "", src = src }

        Nothing ->
            text "preview n/a"


showPreview : FileEntry -> Element Msg
showPreview { imageType, bytes } =
    let
        p =
            imageType |> Maybe.map (showFilePreview bytes)
    in
    Maybe.withDefault (text "preview n/a") p


showStatus : Status -> Element Msg
showStatus s =
    el [ Element.alignRight ] <|
        case s of
            Seeding i ->
                text ("Seeding " ++ String.fromInt i)

            Prepared ->
                text "Prepared"

            Advertised ->
                text "Advertised"

            Requested ->
                text "Requested"

            Loaded ->
                text "Loaded"


showFile : FileEntry -> Element Msg
showFile fileEntry =
    let
        hashView =
            text fileEntry.hash

        seeLogs =
            Input.button [ buttonColor, Element.padding 10, Element.alignRight ] { onPress = Just <| SetLogsVisible fileEntry.hash (not fileEntry.logsVisible), label = text "See logs" }

        logs =
            if fileEntry.logsVisible then
                column [ fillWidth, Element.paddingXY 10 5, Element.spacing 5 ] <| List.map (\l -> el [] <| text l) fileEntry.logs

            else
                Element.none
    in
    column [ fillWidth ]
        [ row [ fillWidth, Element.spacing 10 ]
            [ showPreview fileEntry
            , hashView
            , showStatus fileEntry.status
            , seeLogs
            ]
        , logs
        ]
