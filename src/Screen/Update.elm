module Screen.Update exposing (..)

import Screen.Model exposing (Model)
import Screen.Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WindowResized dc width height ->
            ( { model | device = dc, screenSize = { width = width, height = height } }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
