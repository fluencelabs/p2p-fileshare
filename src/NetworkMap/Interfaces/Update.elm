module NetworkMap.Interfaces.Update exposing (..)

import NetworkMap.Interfaces.Port as Port
import NetworkMap.Interfaces.Model exposing (Model)
import NetworkMap.Interfaces.Msg exposing (Msg(..))

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetInterface peerId ->
            ( model, Port.interfacesRequest { command = "get_interface", id = Just peerId } )

        NoOp ->
            ( model, Cmd.none )
