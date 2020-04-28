module FilesList.Update exposing (update)

import FilesList.Model exposing (Model)
import FilesList.Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )
