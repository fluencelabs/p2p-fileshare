module AddFile.Update exposing (update)

import AddFile.Model exposing (Model)
import AddFile.Msg exposing (Msg(..))
import AddFile.Port exposing (bytesToArray, calcHashBytes)
import Bytes.Decode
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
            ( { model | ipfsHash = "" }, AddFile.Port.addFileByHash model.ipfsHash )

        FileRequested ->
            ( model, Select.file [ "*/*" ] FileProvided )

        FileProvided file ->
            ( model, Task.perform (FileBytesRead file) (File.toBytes file) )

        FileBytesRead file bytes ->
            ( { model | calculatingHashFor = Just { file = file, bytes = bytes } }, calcHashBytes bytes )

        FileHashReceived hash ->
            let
                fileReady f =
                    run <| FileReady f.bytes hash

                cmd =
                    Maybe.withDefault Cmd.none <| Maybe.map fileReady model.calculatingHashFor
            in
            ( { model | calculatingHashFor = Nothing }, cmd )

        _ ->
            ( model, Cmd.none )
