module AddFile.View exposing (view)

import AddFile.Model exposing (Model)
import AddFile.Msg exposing (Msg(..))
import Element exposing (Element, column, el, row, text)
import Element.Events as Events
import Element.Font as Font
import Palette exposing (dropdownBg, fillWidth, h1, layout, link, linkColor)


view : Model -> List (Element Msg)
view addFile =
    let
        a =
            addFile
    in
    [ text "Add File to be there" ]
