module FileSharing.Port exposing (..)

import FileSharing.FilesList.Port
import FileSharing.Model exposing (Model)
import FileSharing.Msg as FileSharingMsg exposing (Msg(..))

subscriptions : Model -> Sub FileSharingMsg.Msg
subscriptions model =
    Sub.batch
        [ FileSharing.FilesList.Port.subscriptions model.filesList |> Sub.map FilesListMsg
        ]