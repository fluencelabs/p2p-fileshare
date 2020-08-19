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
import Model exposing (Model)
import Msg exposing (Msg(..))
import NetworkMap.AvailableModules.Msg
import NetworkMap.Interfaces.Model exposing (CallResult)
import NetworkMap.Interfaces.Msg
import NetworkMap.Interfaces.Port exposing (decodeInterfaceJson)
import Maybe exposing (withDefault, map)
import NetworkMap.WasmUploader.Msg
import Screen.Subscriptions

type alias InterfaceEvent =
    { event : String, interfaces : Maybe Json.Decode.Value, result : Maybe CallResult }

type alias WasmUploaderEvent =
    { event : String, wasmUploaded : Maybe String }

type alias AvailableModulesEvent =
    { event : String, modules : Maybe (List String) }

port interfaceReceiver : (InterfaceEvent -> msg) -> Sub msg
port wasmUploaderReceiver : (WasmUploaderEvent -> msg) -> Sub msg
port availableModulesReceiver : (AvailableModulesEvent -> msg) -> Sub msg

availableModulesEventToMsg : AvailableModulesEvent -> Msg
availableModulesEventToMsg event =
    Maybe.withDefault NoOp <|
        case event.event of
            "set_modules" ->
                map
                    (\result -> AvailableModulesMsg (NetworkMap.AvailableModules.Msg.SetModules result))
                    event.modules
            _ ->
                Nothing

wasmUploaderEventToMsg : WasmUploaderEvent -> Msg
wasmUploaderEventToMsg event =
    Maybe.withDefault NoOp <|
        case event.event of
            "wasm_uploaded" ->
                Just (WasmUploaderMsg NetworkMap.WasmUploader.Msg.WasmUploaded)
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
                        (\result -> (InterfaceMsg (NetworkMap.Interfaces.Msg.AddResult result)))
                        event.result
            _ -> Nothing


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ interfaceReceiver interfaceEventToMsg
        , wasmUploaderReceiver wasmUploaderEventToMsg
        , availableModulesReceiver availableModulesEventToMsg
        , Screen.Subscriptions.subscriptions |> Sub.map ScreenMsg
        ]
