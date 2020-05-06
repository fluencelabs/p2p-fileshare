module AddFile.Update exposing (update)

import AddFile.Model exposing (Model)
import AddFile.Msg exposing (Msg(..))
import AddFile.Port exposing (bytesToList, calcHashBytes)
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
                    let
                        mime =
                            File.mime f.file

                        imageType =
                            if String.startsWith "image/" mime then
                                Just <| String.dropLeft 6 mime

                            else
                                let
                                    firstFourBytes =
                                        case Bytes.Decode.decode (Bytes.Decode.bytes 4) f.bytes of
                                            Just bs ->
                                                bytesToList bs

                                            Nothing ->
                                                []
                                in
                                case firstFourBytes of
                                    [ 255, 216, 255, _ ] ->
                                        Just "jpg"

                                    -- TODO png and gif
                                    _ ->
                                        Nothing
                    in
                    run <| FileReady imageType f.bytes hash

                cmd =
                    Maybe.withDefault Cmd.none <| Maybe.map fileReady model.calculatingHashFor
            in
            ( { model | calculatingHashFor = Nothing }, cmd )

        _ ->
            ( model, Cmd.none )
