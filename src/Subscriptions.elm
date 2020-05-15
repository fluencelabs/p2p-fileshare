module Subscriptions exposing (subscriptions)

import Conn.Port
import FilesList.Port
import Model exposing (Model)
import Msg exposing (Msg(..))
import NetworkMap.Port


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Conn.Port.subscriptions model.connectivity |> Sub.map ConnMsg
        , FilesList.Port.subscriptions model.filesList |> Sub.map FilesListMsg
        , NetworkMap.Port.subscriptions model.networkMap |> Sub.map NetworkMapMsg
        ]
