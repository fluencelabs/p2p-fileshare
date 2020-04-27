module Update exposing (update)

import Model exposing (Model)
import Msg exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetRelay peer ->
            let
                connectivity =
                    model.connectivity
            in
            ( { model | connectivity = { connectivity | relay = Just peer } }, Cmd.none )

        ChoosingRelay choosing ->
            let
                connectivity =
                    model.connectivity
            in
            ( { model | connectivity = { connectivity | choosing = choosing } }, Cmd.none )

        _ ->
            ( model, Cmd.none )
