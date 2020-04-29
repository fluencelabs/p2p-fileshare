module FilesList.Update exposing (update)

import FilesList.Model exposing (Model, Status(..))
import FilesList.Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddFile file bytes hash ->
            let
                entry =
                    { file = Just file
                    , bytes = Just bytes
                    , hash = hash
                    , status = Seeding 13
                    , logs = [ "added from upload" ]
                    , logsVisible = False
                    }

                files =
                    model.files ++ [ entry ]
            in
            ( { model | files = files }, Cmd.none )

        SetLogsVisible hash flag ->
            let
                updateEntry entry =
                    if entry.hash == hash then
                        { entry | logsVisible = flag }

                    else
                        entry

                files =
                    List.map updateEntry model.files
            in
            ( { model | files = files }, Cmd.none )

        _ ->
            ( model, Cmd.none )
