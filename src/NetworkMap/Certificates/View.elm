module NetworkMap.Certificates.View exposing (..)

{-|
  Copyright 2020 Fluence Labs Limited

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

import Element exposing (Element, alignRight, centerX, column, el, fillPortion, padding, paddingXY, paragraph, row, spacing, text, width)
import Element.Font as Font
import Element.Input as Input
import Ions.Background as Background
import Iso8601 exposing (fromTime)
import List exposing (head, sortBy)
import Maybe exposing (andThen)
import NetworkMap.Certificates.Model exposing (Certificate, Model, ShowCertState)
import NetworkMap.Certificates.Msg exposing (Msg(..))
import Palette exposing (fillWidth, limitLayoutWidth, shortHashRaw)
import Screen.Model as Screen
import List.FlatMap exposing (flatMap)
import Array as A exposing (Array)
import Time

view : Screen.Model -> Model -> Element Msg
view screen networkModel =
    column [ fillWidth ]
    (actionView networkModel.id networkModel.certificates networkModel.showCertState)

showCertLink : Int -> Int -> String -> Element Msg
showCertLink certIdx trustIdx id =
    let
        txt = (shortHashRaw 6 id)
        showCertL =
            Input.button
               [ Font.underline ]
               { onPress = Just <| ShowTrust certIdx trustIdx, label = text txt }
    in
        showCertL

millisToISO : Int -> String
millisToISO millis =
    fromTime <| Time.millisToPosix millis

certAttrRowEl : String -> Element Msg -> Element Msg
certAttrRowEl name value =
    row [ paddingXY 0 5, spacing 10 ] [paragraph [ Font.bold ] <| [text name], value]

certAttrRow : String -> String -> Element Msg
certAttrRow name value =
    certAttrRowEl name <| text value

certView : Int -> Certificate -> Maybe Int -> Element Msg
certView certIdx cert showTrust =
    let
        ar = cert.chain
        all = A.indexedMap
                (\i -> \t ->
                    -- last element without arrow
                    if (i == A.length ar - 1) then
                        [ showCertLink certIdx i t.issuedFor ]
                    else
                        [ showCertLink certIdx i t.issuedFor, text " -> " ]
                )
                ar
        list = A.toList all
        until = head <| sortBy (\t -> t.expiresAt) <| A.toList cert.chain
        untilIso = fromTime <| Time.millisToPosix <| Maybe.withDefault 0 <| Maybe.map .expiresAt until
        trustToShow = showTrust
                          |> andThen (\st -> A.get st ar
                          |> andThen (\t -> Just (column [ Background.blackAlpha 30, paddingXY 40 12 ] [
                            certAttrRow "issued for: " t.issuedFor,
                            certAttrRow "expires at: " <| millisToISO t.expiresAt,
                            certAttrRow "issued at: "  <| millisToISO t.issuedAt,
                            certAttrRow "signature: " t.signature
                          ])))
    in
        column [ Background.blackAlpha 20, paddingXY 0 10 ]
        [ row [ spacing 10 ] <| (flatMap (\e -> e) list) ++ [ paragraph [ Font.bold ] [text <| " - until " ++ untilIso]]
        , Maybe.withDefault Element.none trustToShow
        ]

actionView : String -> Array Certificate -> Maybe ShowCertState -> List (Element Msg)
actionView id certs showCertState =
    let
        addCertButton =
            Input.button
               [ padding 10, Background.blackAlpha 60 ]
               { onPress = Just <| AddCertificate id, label = text "Add Cert" }
        getCertButton =
            Input.button
                [ padding 10, Background.blackAlpha 60 ]
                { onPress = Just <| GetCertificate id, label = text "Get Cert" }
        certsView =
            A.indexedMap
                (\i -> \c ->
                    Maybe.withDefault (certView i c Nothing)
                        (Maybe.andThen
                            (\scs ->
                                if (scs.certIdx == i) then
                                    Just (certView i c <| Just scs.trustIdx)
                                else
                                    Just (certView i c Nothing))
                        showCertState)
                )
                certs
    in [ row [ limitLayoutWidth, Background.white, centerX ]
            [ el [ alignRight, padding 5 ] <| addCertButton
            , el [ alignRight, padding 5 ] <| getCertButton
            ]
        ,  column [ fillWidth, limitLayoutWidth, Background.blackAlpha 10, centerX, paddingXY 20 10 ]
            <| A.toList certsView
        ]
