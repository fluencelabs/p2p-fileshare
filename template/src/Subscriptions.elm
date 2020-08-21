port module Subscriptions exposing (subscriptions)

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

import Json.Decode
import Maybe exposing (map, withDefault)
import Model exposing (Model)
import Msg exposing (Msg(..))
import NetworkMap.Interfaces.Model exposing (CallResult)
import NetworkMap.Interfaces.Msg
import NetworkMap.Interfaces.Port exposing (decodeInterfaceJson)
import NetworkMap.Services.Msg
import Screen.Subscriptions


type alias InterfaceEvent =
    { event : String, interfaces : Maybe Json.Decode.Value, result : Maybe CallResult }


type alias ServicesEvent =
    { event : String, modules : Maybe (List String), wasmUploaded : Maybe String }


port interfaceReceiver : (InterfaceEvent -> msg) -> Sub msg


port servicesReceiver : (ServicesEvent -> msg) -> Sub msg


servicesEventToMsg : ServicesEvent -> Msg
servicesEventToMsg event =
    Maybe.withDefault NoOp <|
        case event.event of
            "wasm_uploaded" ->
                Just (ServicesMsg NetworkMap.Services.Msg.WasmUploaded)

            "set_modules" ->
                map
                    (\result -> ServicesMsg (NetworkMap.Services.Msg.UpdateModules result))
                    event.modules

            _ ->
                Nothing


interfaceEventToMsg : InterfaceEvent -> Msg
interfaceEventToMsg event =
    Maybe.withDefault NoOp <|
        case event.event of
            "add_interfaces" ->
                withDefault Nothing <|
                    map
                        (\interface -> Maybe.map InterfaceMsg (decodeInterfaceJson interface))
                        event.interfaces

            "add_result" ->
                map
                    (\result -> InterfaceMsg (NetworkMap.Interfaces.Msg.AddResult result))
                    event.result

            _ ->
                Nothing


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ interfaceReceiver interfaceEventToMsg
        , servicesReceiver servicesEventToMsg
        , Screen.Subscriptions.subscriptions |> Sub.map ScreenMsg
        ]
