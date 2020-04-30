module Subscriptions exposing (subscriptions)

import AddFile.Port
import Conn.Port
import FilesList.Port
import Model exposing (Model)
import Msg exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AddFile.Port.subscriptions model.addFile |> Sub.map AddFileMsg
        , Conn.Port.subscriptions model.connectivity |> Sub.map ConnMsg
        , FilesList.Port.subscriptions model.filesList |> Sub.map FilesListMsg
        ]
