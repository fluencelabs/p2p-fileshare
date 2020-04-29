module Subscriptions exposing (subscriptions)

import AddFile.HashPort
import Model exposing (Model)
import Msg exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    AddFile.HashPort.subscriptions model.addFile |> Sub.map AddFileMsg
