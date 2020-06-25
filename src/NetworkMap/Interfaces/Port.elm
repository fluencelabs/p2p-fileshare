port module NetworkMap.Interfaces.Port exposing (..)

type alias Command =
    { command : String, id : Maybe String }


port interfacesRequest : Command -> Cmd msg