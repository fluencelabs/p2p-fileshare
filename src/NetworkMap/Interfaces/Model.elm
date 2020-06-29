module NetworkMap.Interfaces.Model exposing (..)

import Array exposing (Array)
import Dict exposing (Dict)


type alias Arg =
    String


type alias Call =
    { moduleName : String, fname : String, args : List Arg }


type alias Function =
    { name : String, inputs : Array String, outputs : Array String }


type alias Module =
    { name : String, functions : List Function }


type alias Interface =
    { modules : List Module }


type alias Inputs =
    Dict String (Dict String (Array String))


type alias Model =
    { id : String, interface : Maybe Interface, inputs : Inputs }
