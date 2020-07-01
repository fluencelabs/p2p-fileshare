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
    { moduleName : String, fname : String, args : Maybe (List Arg) }


type alias Function =
    { input_types : Array String, output_types : Array String }


type alias Module =
    { functions : Dict String Function }


type alias Interface =
    { modules : Dict String Module }


type alias Inputs =
    Dict String (Dict String (Array String))


type alias Model =
    { id : String, interface : Maybe Interface, inputs : Inputs }
