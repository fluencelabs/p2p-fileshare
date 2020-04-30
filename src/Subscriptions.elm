module Subscriptions exposing (subscriptions)

import AddFile.HashPort
import Conn.Port
import Model exposing (Model)
import Msg exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AddFile.HashPort.subscriptions model.addFile |> Sub.map AddFileMsg
        , Conn.Port.subscriptions model.connectivity |> Sub.map ConnMsg
        ]
