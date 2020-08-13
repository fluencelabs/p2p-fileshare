module NetworkMap.CreateService.Update exposing (..)

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
import NetworkMap.CreateService.Model exposing (Model)
import NetworkMap.CreateService.Msg exposing (Msg(..))
import NetworkMap.CreateService.Port as Port


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetAvailableModules id ->
            ( model, Port.createServiceRequest { command = "get_modules", id = id, modules = Nothing } )

        CreateService ->
            let
                modulesPairs =
                    Multiselect.getSelectedValues model.multiselect

                modules =
                    List.map Tuple.first modulesPairs
            in
            ( model, Port.createServiceRequest { command = "create_service", id = model.id, modules = Just modules } )

        UpdateModules modules ->
            let
                pairs =
                    List.map (\m -> ( m, m )) modules

                newMultiselect =
                    Multiselect.populateValues model.multiselect pairs []
            in
            ( { model | multiselect = newMultiselect }, Cmd.none )

        UpdateMultiSelect msMsg ->
            let
                a =
                    model.multiselect

                ( subModel, subCmd, _ ) =
                    Multiselect.update msMsg model.multiselect
            in
            ( { model | multiselect = subModel }, Cmd.map UpdateMultiSelect subCmd )
