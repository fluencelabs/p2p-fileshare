module NetworkMap.Interfaces.Model exposing (..)

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


type alias Arg =
    String


type alias Call =
    { serviceId : String, moduleName : String, fname : String, args : Maybe (List Arg) }


type alias CallResult =
    { serviceId : String, moduleName : String, fname : String, result : String }


type alias Function =
    { name : String, input_types : Array String, output_types : Array String }


type alias Module =
    { name : String, functions : List Function }


type alias Interface =
    { name : String, modules : List Module }


type alias Input =
    ( ( String, String, String ), Array String )


type alias Inputs =
    Dict ( String, String, String ) (Array String)


type alias Results =
    Dict ( String, String, String ) String


type alias Model =
    { id : String, interfaces : List Interface, isOpenedInterfaces : Dict String Bool, inputs : Inputs, results : Results }
