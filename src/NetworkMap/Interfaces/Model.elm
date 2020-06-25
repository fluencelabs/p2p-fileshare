module NetworkMap.Interfaces.Model exposing (..)


type alias Function =
    { name : String, inputs : List String, outputs : List String }


type alias Module =
    { name : String, functions : List Function }


type alias Interface =
    { modules : List Module }


type alias Model =
    { interface : Maybe Interface }
