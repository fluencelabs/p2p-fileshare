module AddFile.Update exposing (update)

import AddFile.Model exposing (Model)
import AddFile.Msg exposing (Msg(..))
import File.Select as Select


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
            Debug.log (Debug.toString file) <|
                ( model, Cmd.none )
