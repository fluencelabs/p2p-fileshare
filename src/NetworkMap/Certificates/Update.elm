module NetworkMap.Certificates.Update exposing (..)

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

import Array exposing (Array)
import Dict exposing (Dict)
import List
import List.FlatMap
import List.Unique
import NetworkMap.Certificates.Model exposing (Certificate, CertificateMask, Model, Trust)
import NetworkMap.Certificates.Msg exposing (Msg(..))
import NetworkMap.Certificates.Port as Port
import Utils.ArrayExtras as ArrayExtras


convertCert : Certificate -> List ( String, String, Trust )
convertCert cert =
    let
        chain =
            cert.chain

        ( _, pairs ) =
            chain |> Array.foldl folder ( Nothing, [] )
    in
    pairs


folder : Trust -> ( Maybe String, List ( String, String, Trust ) ) -> ( Maybe String, List ( String, String, Trust ) )
folder t acc =
    let
        ( previous, pairs ) =
            acc

        pr =
            previous |> Maybe.withDefault t.issuedFor
    in
    ( Just t.issuedFor, pairs ++ [ ( pr, t.issuedFor, t ) ] )


updateTrust : Trust -> Maybe Trust -> Maybe Trust
updateTrust trust previousTrust =
    let
        updated =
            previousTrust
                |> Maybe.map
                    (\t ->
                        if t.issuedAt < trust.issuedAt then
                            trust

                        else
                            t
                    )

        actualTrust =
            Maybe.withDefault trust updated
    in
    Just actualTrust


updateDict : ( String, String, Trust ) -> Dict ( String, String ) Trust -> Dict ( String, String ) Trust
updateDict pairWithTrust dict =
    let
        ( prev, cur, trust ) =
            pairWithTrust

        pair =
            ( prev, cur )

        updated =
            dict |> Dict.update pair (updateTrust trust)
    in
    updated


updateTrusts : List ( String, String, Trust ) -> Dict ( String, String ) Trust -> Dict ( String, String ) Trust
updateTrusts pairs storage =
    let
        updated =
            pairs |> List.foldl updateDict storage
    in
    updated


certEquals : CertificateMask -> CertificateMask -> Bool
certEquals l r =
    l == r


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CertificatesAdded array ->
            let
                pairs =
                    array |> Array.map convertCert

                certMasks =
                    pairs |> Array.map (\ps -> { trustIds = Array.fromList (ps |> List.map (\( l, r, _ ) -> ( l, r ))) })

                uniqueMasks =
                    List.Unique.filterDuplicates (Array.toList certMasks) |> Array.fromList

                allPairs =
                    List.FlatMap.flatMap (\l -> l) (Array.toList pairs)

                updated =
                    updateTrusts allPairs model.trusts

                uniquePairs =
                    uniqueMasks |> Array.filter (\p -> not (model.certificates |> ArrayExtras.contains (certEquals p)))
            in
            ( { model | certificates = Array.append model.certificates uniquePairs, trusts = updated }, Cmd.none )

        AddCertificate id ->
            ( model, Port.certificatesRequest { command = "issue", id = Just id } )

        GetCertificate id ->
            ( model, Port.certificatesRequest { command = "get_cert", id = Just id } )

        ShowTrust certIdx trustIdx ->
            ( { model | showCertState = Just { certIdx = certIdx, trustIdx = trustIdx } }, Cmd.none )

        ChangeFocus _ ->
            -- this msg is for parent model only
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
