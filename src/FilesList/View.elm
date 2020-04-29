module FilesList.View exposing (view)

import Base64.Encode as Encode
import Bytes exposing (Bytes)
import Element exposing (Element, column, el, row, text)
import Element.Input as Input
import File exposing (File)
import FilesList.Model exposing (FileEntry, Model, Status(..))
import FilesList.Msg exposing (Msg(..))
import Palette exposing (buttonColor, fillWidth)


view : Model -> List (Element Msg)
view { files } =
    let
        filesList =
            files |> List.map showFile
    in
    filesList


showFilePreview : Maybe Bytes -> File -> Element Msg
showFilePreview maybeBytes file =
    let
        mime =
            File.mime file

        name =
            File.name file

        description =
            mime ++ " " ++ name

        imgPreviewSrc =
            case maybeBytes of
                Just bytes ->
                    if String.startsWith "image/" mime then
                        Just <| "data:" ++ mime ++ ";base64," ++ Encode.encode (Encode.bytes bytes)

                    else
                        Nothing

                Nothing ->
                    Nothing
    in
    case imgPreviewSrc of
        Just src ->
            Element.image [ Element.width <| Element.px 30, Element.height <| Element.px 30 ] { description = description, src = src }

        Nothing ->
            text description


showPreview : FileEntry -> Element Msg
showPreview { file, bytes } =
    let
        p =
            file |> Maybe.map (showFilePreview bytes)
    in
    Maybe.withDefault (text "no preview available") p


showStatus : Status -> Element Msg
showStatus s =
    case s of
        Seeding i ->
            text ("Seeding " ++ String.fromInt i)


showFile : FileEntry -> Element Msg
showFile fileEntry =
    let
        hashView =
            text fileEntry.hash

        seeLogs =
            Input.button [ buttonColor, Element.padding 10 ] { onPress = Nothing, label = text "See logs" }
    in
    row [ fillWidth, Element.spacing 10 ]
        [ showPreview fileEntry
        , hashView
        , showStatus fileEntry.status
        , seeLogs
        ]
