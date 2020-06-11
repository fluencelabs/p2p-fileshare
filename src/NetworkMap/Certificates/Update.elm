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

import Array
import NetworkMap.Certificates.Model exposing (Model)
import NetworkMap.Certificates.Msg exposing (Msg(..))
import NetworkMap.Certificates.Port as Port


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CertificatesAdded array ->
            ( { model | certificates = Array.append model.certificates array }, Cmd.none )

        AddCertificate id ->
            ( model, Port.certificatesRequest { command = "issue", id = Just id } )

        GetCertificate id ->
            ( model, Port.certificatesRequest { command = "get_cert", id = Just id } )

        ShowTrust certIdx trustIdx ->
            ( { model | showCertState = Just { certIdx = certIdx, trustIdx = trustIdx } }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
