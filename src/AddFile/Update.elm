module AddFile.Update exposing (update)

import AddFile.HashPort exposing (calcHashBytes)
import AddFile.Model exposing (Model)
import AddFile.Msg exposing (Msg(..))
import File exposing (File)
import File.Select as Select
import Platform.Cmd exposing (Cmd(..))
import Task


run : msg -> Cmd msg
run m =
    Task.perform (always m) (Task.succeed ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetVisible v ->
            ( { model | visible = v }, Cmd.none )

        ChangeIpfsHash hash ->
            ( { model | ipfsHash = hash }, Cmd.none )

        DownloadIpfs ->
            ( { model | ipfsHash = "" }, Cmd.none )

        FileRequested ->
            ( model, Select.file [ "*/*" ] FileProvided )

        FileProvided file ->
            ( model, Task.perform (FileBytesRead file) (File.toBytes file) )

        FileBytesRead file bytes ->
            ( { model | calculatingHashFor = Just file }, calcHashBytes bytes )

        FileHashReceived hash ->
            let
                fileReady f =
                    run <| FileReady f hash

                cmd =
                    Maybe.withDefault Cmd.none <| Maybe.map fileReady model.calculatingHashFor
            in
            ( { model | calculatingHashFor = Nothing }, cmd )

        _ ->
            ( model, Cmd.none )
