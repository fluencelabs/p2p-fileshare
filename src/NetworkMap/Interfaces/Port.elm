port module NetworkMap.Interfaces.Port exposing (..)

import NetworkMap.Interfaces.Model exposing (Call)


type alias Command =
    { command : String, id : Maybe String, call : Maybe Call }


port interfacesRequest : Command -> Cmd msg
