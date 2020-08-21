module NetworkMap.Services.Update exposing (..)

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

import Multiselect
import NetworkMap.Services.Model exposing (Model)
import NetworkMap.Services.Msg exposing (Msg(..))
import NetworkMap.Services.Port as Port


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetAvailableModules id ->
            ( model, Port.servicesRequest { command = "get_modules", id = id, modules = Nothing, name = Nothing } )

        CreateService ->
            let
                modulesPairs =
                    Multiselect.getSelectedValues model.multiselect

                modules =
                    List.map Tuple.first modulesPairs
            in
            ( model, Port.servicesRequest { command = "create_service", id = model.id, modules = Just modules, name = Nothing } )

        UpdateModules modules ->
            let
                pairs =
                    List.map (\m -> ( m, m )) modules

                newMultiselect =
                    Multiselect.populateValues model.multiselect pairs []
            in
            ( { model | multiselect = newMultiselect, modules = modules }, Cmd.none )

        UpdateMultiSelect msMsg ->
            let
                ( subModel, subCmd, _ ) =
                    Multiselect.update msMsg model.multiselect
            in
            ( { model | multiselect = subModel }, Cmd.map UpdateMultiSelect subCmd )

        UploadWasm ->
            ( model, Port.servicesRequest { command = "upload_wasm", id = model.id, modules = Nothing, name = Just model.moduleName } )

        WasmUploaded ->
            ( model, Cmd.none )

        ChangeName name ->
            ( { model | moduleName = name }, Cmd.none )
