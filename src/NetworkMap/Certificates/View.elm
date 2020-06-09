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

import Element exposing (Element, alignRight, centerX, column, el, padding, row, text)
import Element.Input as Input
import Ions.Background as Background
import Iso8601 exposing (fromTime)
import List exposing (head, sortBy)
import Maybe exposing (andThen)
import NetworkMap.Certificates.Model exposing (Certificate, Model, ShowCertState)
import NetworkMap.Certificates.Msg exposing (Msg(..))
import Palette exposing (limitLayoutWidth, shortHashRaw)
import Screen.Model as Screen
import Array as A exposing (Array)
import Time

view : Screen.Model -> Model -> Element Msg
view screen networkModel =
    column []
    (actionView networkModel.id networkModel.certificates networkModel.showCertState)

showCertLink : Int -> Int -> String -> Bool -> Element Msg
showCertLink certIdx trustIdx id sep =
    let
        txt = (shortHashRaw 6 id)
        showCertL =
            Input.button
               []
               { onPress = Just <| ShowTrust certIdx trustIdx, label = text (if (sep) then txt ++ " -> " else txt) }
    in
        showCertL

certViewAr : Int -> Certificate -> Maybe Int -> Element Msg
certViewAr certIdx cert showTrust =
    let
        ar = cert.chain
        all = A.indexedMap (\i -> \t ->
            if (i == A.length ar - 1) then
                showCertLink certIdx i t.issuedFor False
            else
                showCertLink certIdx i t.issuedFor True) ar
        list = A.toList all
        until = head <| sortBy (\t -> t.expiresAt) <| A.toList cert.chain
        untilIso = fromTime <| Time.millisToPosix <| Maybe.withDefault 0 <| Maybe.map .expiresAt until
        trustToShow = showTrust
                          |> andThen (\st -> A.get st ar
                          |> andThen (\t -> Just (column [] [
                            row [] [text t.issuedFor],
                            row [] [text <| String.fromInt t.expiresAt],
                            row [] [text <| String.fromInt  t.issuedAt],
                            row [] [text t.signature]
                            ])))
    in
        column []
        [ row [] <| list ++ [text <| " - until " ++ untilIso]
        , Maybe.withDefault Element.none trustToShow
        ]

actionView : String -> Array Certificate -> Maybe ShowCertState -> List (Element Msg)
actionView id certs showCertState =
    let
        addCertButton =
            Input.button
               []
               { onPress = Just <| AddCertificate id, label = text "Add Cert" }
        getCertButton =
            Input.button
                []
                { onPress = Just <| GetCertificate id, label = text "Get Cert" }
        certsView =
            A.indexedMap
                (\i -> \c ->
                    Maybe.withDefault (certViewAr i c Nothing)
                        (Maybe.andThen
                            (\scs ->
                                if (scs.certIdx == i) then
                                    Just (certViewAr i c <| Just scs.trustIdx)
                                else
                                    Just (certViewAr i c Nothing))
                        showCertState)
                )
                certs
    in [ row [ limitLayoutWidth, Background.white, centerX ]
            [ el [ alignRight, padding 10 ] <| addCertButton
            , el [ alignRight, padding 10 ] <| getCertButton
            ]
        ,  row [ limitLayoutWidth, Background.white, centerX ]
            <| A.toList certsView
        ]