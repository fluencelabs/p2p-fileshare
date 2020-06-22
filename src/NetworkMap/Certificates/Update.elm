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
import NetworkMap.Certificates.Model exposing (Certificate, CertificateIds, Model, Trust)
import NetworkMap.Certificates.Msg exposing (Msg(..))
import NetworkMap.Certificates.Port as Port
import Utils.ArrayExtras as ArrayExtras


type alias TrustExt =
    { issuedBy : String
    , issuedFor : String
    , trust : Trust
    }


convertCertToTrustExtChain : Certificate -> List TrustExt
convertCertToTrustExtChain cert =
    let
        chain =
            cert.chain

        ( _, pairs ) =
            chain |> Array.foldl gatherPairs ( Nothing, [] )
    in
    pairs


gatherPairs : Trust -> ( Maybe String, List TrustExt ) -> ( Maybe String, List TrustExt )
gatherPairs t acc =
    let
        ( previous, pairs ) =
            acc

        pr =
            previous |> Maybe.withDefault t.issuedFor
    in
    ( Just t.issuedFor, pairs ++ [ { issuedBy = pr, issuedFor = t.issuedFor, trust = t } ] )


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


updateTrusts : TrustExt -> Dict ( String, String ) Trust -> Dict ( String, String ) Trust
updateTrusts trust dict =
    let
        updated =
            dict |> Dict.update ( trust.issuedBy, trust.issuedFor ) (updateTrust trust.trust)
    in
    updated


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CertificatesAdded array ->
            let
                pairs =
                    array |> Array.map convertCertToTrustExtChain

                certIds =
                    pairs |> Array.map (\ps -> { trustIds = Array.fromList (ps |> List.map (\t -> ( t.issuedBy, t.issuedFor ))) })

                uniqueIds =
                    List.Unique.filterDuplicates (Array.toList certIds) |> Array.fromList

                allPairs =
                    List.FlatMap.flatMap (\l -> l) (Array.toList pairs)

                updatedTrusts =
                    allPairs |> List.foldl updateTrusts model.trusts

                -- don't add the same certificates in model
                uniquePairs =
                    uniqueIds |> Array.filter (\p -> not (model.certificates |> ArrayExtras.contains ((==) p)))
            in
            ( { model | certificates = Array.append model.certificates uniquePairs, trusts = updatedTrusts }, Cmd.none )

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
