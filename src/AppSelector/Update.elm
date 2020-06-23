module AppSelector.Update exposing (..)

import AppSelector.Model exposing (Model)
import AppSelector.Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChooseApp app ->
            ( { model | currentApp = app }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
