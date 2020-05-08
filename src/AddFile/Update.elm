module AddFile.Update exposing (update)

import AddFile.Model exposing (Model)
import AddFile.Msg exposing (Msg(..))
import AddFile.Port
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
            ( model, AddFile.Port.selectFile () )
