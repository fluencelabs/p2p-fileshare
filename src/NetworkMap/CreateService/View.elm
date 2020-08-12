module NetworkMap.CreateService.View exposing (..)

import Element exposing (Element, column, padding, spacing, text)
import Html
import Multiselect
import NetworkMap.CreateService.Model exposing (Model)
import NetworkMap.CreateService.Msg exposing (Msg(..))
import Palette exposing (fillWidth)
import Screen.Model as Screen


view : Screen.Model -> Model -> Element Msg
view screen model =
    let
        ms = Multiselect.view model.multiselectA
        m = Html.map UpdateMultiSelect <| ms
        multiselect =
            Element.html (m)
    in
    column [ fillWidth ]
            [multiselect]
