module Update exposing (update)

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

import Model exposing (Model)
import Msg exposing (..)
import NetworkMap.Interfaces.Update
import NetworkMap.Services.Update
import Screen.Update


liftUpdate :
    (Model -> model)
    -> (model -> Model -> Model)
    -> (msg -> Msg)
    -> (msg -> model -> ( model, Cmd msg ))
    -> (msg -> Model -> ( Model, Cmd Msg ))
liftUpdate getModel setModel liftMsg updateComponent =
    \msg ->
        \model ->
            let
                m =
                    getModel model

                ( updatedComponentModel, modelCmd ) =
                    updateComponent msg m
            in
            ( setModel updatedComponentModel model
            , Cmd.map liftMsg modelCmd
            )


updateInterface =
    liftUpdate .interface (\c -> \m -> { m | interface = c }) InterfaceMsg NetworkMap.Interfaces.Update.update


updateServices =
    liftUpdate .services (\c -> \m -> { m | services = c }) ServicesMsg NetworkMap.Services.Update.update


updateScreen =
    liftUpdate .screen (\s -> \m -> { m | screen = s }) ScreenMsg Screen.Update.update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InterfaceMsg m ->
            updateInterface m model

        ServicesMsg m ->
            updateServices m model

        ScreenMsg m ->
            updateScreen m model

        NoOp ->
            ( model, Cmd.none )
