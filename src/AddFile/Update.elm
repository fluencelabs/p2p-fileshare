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
                                    firstEightBytes =
                                        case Bytes.Decode.decode (Bytes.Decode.bytes 8) f.bytes of
                                            Just bs ->
                                                bytesToList bs

                                            Nothing ->
                                                []
                                in

                                case firstEightBytes of
                                    [ 0xFF, 0xD8, 0xFF, _, _, _, _, _] ->
                                        Just "jpeg"
                                    [ 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A] ->
                                        Just "png"
                                    [ 0x47, 0x49, 0x46, _ , _, _, _, _] ->
                                        Just "gif"
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
