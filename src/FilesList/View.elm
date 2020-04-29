module FilesList.View exposing (view)

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


showFilePreview : File -> Element Msg
showFilePreview file =
    let
        mime =
            File.mime file

        name =
            File.name file
    in
    text <| (mime ++ name)


showPreview : FileEntry -> Element Msg
showPreview { file } =
    let
        p =
            file |> Maybe.map showFilePreview
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
