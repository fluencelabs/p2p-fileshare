port module NetworkMap.Interfaces.Port exposing (..)

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
import Json.Decode exposing (Decoder, Value, array, decodeValue, field, list, string)
import NetworkMap.Interfaces.Model exposing (Call)
import NetworkMap.Interfaces.Model exposing (CallResult, Function, Interface, Module)
import NetworkMap.Interfaces.Msg exposing (Msg(..))


type alias Command =
    { command : String, id : Maybe String, call : Maybe Call }


port interfacesRequest : Command -> Cmd msg

decodeInterfaceJson : Value -> Maybe Msg
decodeInterfaceJson v =
    let
        interfaces =
            decodeValue decodeInterfaces v

        msg =
            case interfaces of
                Ok value ->
                    Just (AddInterfaces <| value)

                Err error ->
                    Nothing
    in
    msg

decodeStringList : Decoder (Array String)
decodeStringList =
    array string


decodeFunction : Decoder Function
decodeFunction =
    Json.Decode.map3 Function
        (field "name" string)
        (field "input_types" decodeStringList)
        (field "output_types" decodeStringList)


decodeInterfaces : Decoder (List Interface)
decodeInterfaces =
    list decodeInterface


decodeInterface : Decoder Interface
decodeInterface =
    Json.Decode.map2 Interface
        (field "service_id" string)
        (field "modules" (list decodeModule))


decodeModule : Decoder Module
decodeModule =
    Json.Decode.map2 Module
        (field "name" string)
        (field "functions" (list decodeFunction))
