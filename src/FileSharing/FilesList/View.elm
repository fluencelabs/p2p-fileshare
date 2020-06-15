module FilesList.View exposing (view)

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

import Element exposing (Element, alignLeft, alignRight, centerX, centerY, column, el, fillPortion, height, padding, paddingXY, paragraph, px, row, spacing, text, width)
import Element.Border exposing (dashed, dotted)
import Element.Events
import Element.Font as Font
import Element.Input as Input
import Element.Lazy exposing (lazy)
import FilesList.Model exposing (FileEntry, Model, Status(..))
import FilesList.Msg exposing (Msg(..))
import Ions.Background as BG
import Ions.Border as B
import Ions.Font as F
import Palette exposing (blockBackground, fillWidth, layoutBlock, limitLayoutWidth, shortHash, showHash)
import Screen.Model as Screen exposing (isMedium, isNarrow)


view : Screen.Model -> Model -> Element Msg
view screen { files } =
    let
        isMediumSize =
            isMedium screen

        table =
            if List.isEmpty files then
                [ el
                    [ limitLayoutWidth
                    , padding
                        (if isMediumSize then
                            30

                         else
                            60
                        )
                    , F.size6
                    , Font.italic
                    , Font.center
                    , centerX
                    , B.black
                    , B.width1 B.Bottom
                    ]
                  <|
                    text "Please add a file to be shown"
                ]

            else if isMediumSize then
                files |> List.map (showFileLazy screen)

            else
                [ row [ limitLayoutWidth, spacing 15, F.gray, Font.bold ]
                    [ el [ alignLeft, width <| fillPortion 1 ] <| text "PREVIEW"
                    , el [ centerX, width <| fillPortion 7 ] <| text "FILE"
                    , el [ centerX, width <| fillPortion 1 ] <| text "STATUS"
                    , el [ alignRight, width <| fillPortion 1 ] <| text "LOGS"
                    ]
                ]
                    ++ (files |> List.map (showFileLazy screen))
    in
    column (layoutBlock screen ++ [ blockBackground ]) <| table


showFilePreview : Int -> Maybe String -> Element Msg
showFilePreview size maybePreview =
    case maybePreview of
        Just src ->
            Element.image
                [ width <| Element.px size
                , height <| Element.px size
                , centerX
                , centerY
                ]
                { description = "", src = src }

        Nothing ->
            el [ centerY, centerX ] <| text "n/a"


showPreview : Bool -> FileEntry -> Element Msg
showPreview isPhone { preview, hash } =
    let
        size =
            if isPhone then
                30

            else
                66

        p =
            showFilePreview (size - 2) preview
    in
    el
        [ Element.Events.onClick <| DownloadFile hash
        , width (px size)
        , height (px size)
        , Font.center
        , BG.nearBlack
        , F.nearWhite
        , Element.pointer
        ]
    <|
        p


showStatus : Status -> Element Msg
showStatus s =
    el [ Element.alignLeft, F.green, Font.bold, width <| Element.px 84 ] <|
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

            Uploading ->
                text "Uploading..."

            Downloading ->
                text "Downloading..."


showFileLazy : Screen.Model -> FileEntry -> Element Msg
showFileLazy screen =
    lazy (showFile screen)


showFile : Screen.Model -> FileEntry -> Element Msg
showFile screen fileEntry =
    let
        isMediumSize =
            isMedium screen

        isNarrowSize =
            isNarrow screen

        hashView =
            el [ alignLeft ] <|
                (if isNarrowSize then
                    shortHash

                 else
                    showHash
                )
                    fileEntry.hash

        shareButton =
            Input.button
                [ Element.padding 5
                , width <| Element.px 64
                , Font.center
                , alignLeft
                , B.width1 B.AllSides
                , dotted
                , B.gray
                ]
            <|
                { onPress = Just <| Copy fileEntry.hash
                , label =
                    text
                        (if fileEntry.hashCopied then
                            "Copied!"

                         else
                            "Share"
                        )
                }

        seeLogsText =
            if fileEntry.logsVisible then
                "Hide Logs"

            else
                "Show Logs"

        seeLogs =
            Input.button
                [ width <| Element.px 80 ]
            <|
                { onPress = Just <| SetLogsVisible fileEntry.hash (not fileEntry.logsVisible)
                , label =
                    Element.el
                        [ Font.underline
                        ]
                        (Element.text seeLogsText)
                }

        logs =
            if fileEntry.logsVisible then
                column
                    [ limitLayoutWidth
                    , centerX
                    , Element.paddingXY 25 10
                    , spacing 5
                    , BG.white
                    , B.width1 B.Left
                    , B.gray
                    , dashed
                    ]
                <|
                    List.map (\l -> paragraph [ F.code ] [ text <| "> " ++ l ]) fileEntry.logs

            else
                Element.none
    in
    if isMediumSize then
        column [ fillWidth, paddingXY 0 10, B.width005 B.Bottom, B.lightSilver ]
            [ row [ limitLayoutWidth, centerX, paddingXY 0 10, spacing 10 ]
                [ Element.el [ width <| fillPortion 1 ] <| showPreview isNarrowSize fileEntry
                , Element.el [ width <| fillPortion 6, fillWidth ] <| hashView
                , Element.el [ width <| fillPortion 1 ] <| shareButton
                ]
            , row [ limitLayoutWidth, centerX, paddingXY 0 10, spacing 10 ]
                [ Element.el [ width <| fillPortion 1 ] <| showStatus fileEntry.status
                , Element.el [ width <| fillPortion 6, fillWidth ] Element.none
                , Element.el [ width <| fillPortion 1 ] <| seeLogs
                ]
            , logs
            ]

    else
        column [ fillWidth, paddingXY 0 10, B.width005 B.Bottom, B.lightSilver ]
            [ row [ limitLayoutWidth, centerX, spacing 15 ]
                [ Element.el [ width <| fillPortion 1 ] <| showPreview False fileEntry
                , Element.el [ width <| fillPortion 6 ] <| hashView
                , Element.el [ width <| fillPortion 1 ] <| shareButton
                , Element.el [ width <| fillPortion 1 ] <| showStatus fileEntry.status
                , Element.el [ width <| fillPortion 1 ] <| seeLogs
                ]
            , logs
            ]
