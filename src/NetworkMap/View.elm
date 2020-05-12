module NetworkMap.View exposing (view)

import NetworkMap.Model exposing (Model)
import NetworkMap.Msg exposing (Msg(..))
import Element exposing (Element, text)

view : Model -> Element Msg
view networkModel =
    let str = Debug.toString networkModel
    in
        text str
