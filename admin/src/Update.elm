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

import AppSelector.Update
import Conn.Update
import FileSharing.Update
import Model exposing (Model)
import Msg exposing (..)
import NetworkMap.Update
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


updateConn =
    liftUpdate .connectivity (\c -> \m -> { m | connectivity = c }) ConnMsg Conn.Update.update


updateFileSharing =
    liftUpdate .fileSharing (\c -> \m -> { m | fileSharing = c }) FileSharingMsg FileSharing.Update.update


updateNetworkMap =
    liftUpdate .networkMap (\c -> \m -> { m | networkMap = c }) NetworkMapMsg NetworkMap.Update.update


updateAppSelector =
    liftUpdate .appSelector (\c -> \m -> { m | appSelector = c }) AppSelectorMsg AppSelector.Update.update


updateScreen =
    liftUpdate .screen (\s -> \m -> { m | screen = s }) ScreenMsg Screen.Update.update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ConnMsg m ->
            updateConn m model

        FileSharingMsg m ->
            updateFileSharing m model

        NetworkMapMsg m ->
            updateNetworkMap m model

        ScreenMsg m ->
            updateScreen m model

        AppSelectorMsg m ->
            updateAppSelector m model

        NoOp ->
            ( model, Cmd.none )
