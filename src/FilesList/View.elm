module FilesList.View exposing (view)

import Base64.Encode as Encode
import Bytes exposing (Bytes)
import Element exposing (Element, alignRight, centerX, centerY, column, el, height, mouseOver, padding, paddingXY, paragraph, px, row, text, width)
import Element.Border exposing (dashed)
import Element.Events
import Element.Font as Font
import Element.Input as Input
import FilesList.Model exposing (FileEntry, Model, Status(..))
import FilesList.Msg exposing (Msg(..))
import Ions.Background as BG
import Ions.Border as B
import Ions.Font as F
import Palette exposing (fillWidth, limitLayoutWidth, shortHash)


view : Model -> List (Element Msg)
view { files } =
    let
        filesList =
            if List.isEmpty files then
                [ el [ limitLayoutWidth, padding 60, F.size6, Font.italic, Font.center, centerX, B.black, B.width1 B.Bottom ] <| text "Please add a file to be shown" ]

            else
                files |> List.map showFile
    in
    [ row [ fillWidth, F.white, F.size2, BG.black, padding 20 ]
        [ el [ centerX ] <| text "Provided & Discovered files:"
        ]
    ]
        ++ filesList


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
            Element.image
                [ width <| Element.px 30
                , height <| Element.px 30
                , centerX
                , centerY
                ]
                { description = "", src = src }

        Nothing ->
            text "preview n/a"


showPreview : FileEntry -> Element Msg
showPreview { hash, imageType, bytes } =
    let
        p =
            imageType |> Maybe.map (showFilePreview bytes)
    in
    el
        [ Element.Events.onClick <| DownloadFile hash
        , width (px 40)
        , height (px 40)
        , Font.center
        , BG.nearBlack
        , F.nearWhite
        , Element.pointer
        ]
    <|
        Maybe.withDefault (el [ centerY, centerX ] <| text "n/a") p


showStatus : Status -> Element Msg
showStatus s =
    el [ Element.alignRight, Font.center, BG.washedGreen, padding 11 ] <|
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
            el [ Font.family [ Font.monospace ], Font.alignRight, centerX ] <| text fileEntry.hash

        seeLogsStyles =
            if fileEntry.logsVisible then
                [ BG.lightestBlue ]

            else
                []

        seeLogs =
            Input.button
                ([ B.width1 B.AllSides
                 , B.darkGray
                 , padding 10
                 , alignRight
                 ]
                    ++ seeLogsStyles
                )
            <|
                { onPress = Just <| SetLogsVisible fileEntry.hash (not fileEntry.logsVisible)
                , label = text "See logs"
                }

        logs =
            if fileEntry.logsVisible then
                column
                    [ limitLayoutWidth
                    , centerX
                    , Element.paddingXY 45 20
                    , Element.spacing 5
                    , BG.whiteAlpha 850
                    , B.width1 B.Left
                    , B.gray
                    , dashed
                    ]
                <|
                    List.map (\l -> paragraph [ Font.family [ Font.monospace ] ] [ text <| "> " ++ l ]) fileEntry.logs

            else
                Element.none
    in
    column [ fillWidth, paddingXY 0 10, mouseOver [ BG.washedRed ], B.width1 B.Bottom, B.nearBlack ]
        [ row [ limitLayoutWidth, BG.white, centerX ]
            [ showPreview fileEntry
            , hashView
            , showStatus fileEntry.status
            , seeLogs
            ]
        , logs
        ]
