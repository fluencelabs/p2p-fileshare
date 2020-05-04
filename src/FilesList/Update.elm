module FilesList.Update exposing (update)

import Bytes exposing (Bytes)
import Bytes.Encode
import File
import FilesList.Model exposing (FileEntry, Model, Status(..))
import FilesList.Msg exposing (Msg(..))
import FilesList.Port


updateEntry : Model -> String -> (FileEntry -> FileEntry) -> Model
updateEntry model hash up =
    let
        updateFile entry =
            if entry.hash == hash then
                up entry

            else
                entry

        files =
            List.map updateFile model.files
    in
    { model | files = files }


encodeBytes : List Int -> Bytes
encodeBytes arr =
    Bytes.Encode.encode <|
        Bytes.Encode.sequence <|
            List.map Bytes.Encode.unsignedInt8 arr


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetLogsVisible hash flag ->
            let
                updatedModel =
                    updateEntry model hash (\e -> { e | logsVisible = flag })
            in
            ( updatedModel, Cmd.none )

        DownloadFile hash ->
            ( model, FilesList.Port.fileRequest { command = "download", hash = Just hash } )

        AddFile imageType bytes hash ->
            if List.any (\f -> f.hash == hash) model.files then
                ( model, Cmd.none )

            else
                let
                    entry =
                        { imageType = imageType
                        , bytes = Just bytes
                        , hash = hash
                        , status = Prepared
                        , logs = [ "added from upload" ]
                        , logsVisible = False
                        }

                    files =
                        model.files ++ [ entry ]
                in
                ( { model | files = files }, FilesList.Port.fileRequest { command = "advertise", hash = Just hash } )

        FileRequested hash ->
            if List.any (\f -> f.hash == hash) model.files then
                ( model, Cmd.none )

            else
                let
                    entry =
                        { imageType = Nothing
                        , bytes = Nothing
                        , hash = hash
                        , status = Requested
                        , logs = [ "just requested to download" ]
                        , logsVisible = False
                        }

                    files =
                        model.files ++ [ entry ]
                in
                ( { model | files = files }, Cmd.none )

        FileLoaded hash data imageType ->
            let
                updatedModel =
                    updateEntry model hash (\e -> { e | status = Loaded, bytes = Just <| encodeBytes data, imageType = imageType })
            in
            ( updatedModel, Cmd.none )

        FileAdvertised hash ->
            let
                updatedModel =
                    updateEntry model hash (\e -> { e | status = Advertised })
            in
            ( updatedModel, Cmd.none )

        FileLog hash log ->
            let
                updatedModel =
                    updateEntry model hash (\e -> { e | logs = e.logs ++ [ log ] })
            in
            ( updatedModel, Cmd.none )

        FileAsked hash ->
            let
                updatedModel =
                    updateEntry model
                        hash
                        (\e ->
                            let
                                st =
                                    case e.status of
                                        Seeding i ->
                                            Seeding (i + 1)

                                        _ ->
                                            Seeding 1
                            in
                            { e | status = st }
                        )
            in
            ( updatedModel, Cmd.none )

        _ ->
            ( model, Cmd.none )
