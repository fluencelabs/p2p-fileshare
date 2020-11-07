module Blog.View exposing (..)

import Blog.Model exposing (Model)
import Blog.Msg exposing (Msg(..))
import Element exposing (Element, centerX, column, el, fillPortion, none, paddingXY, row, text, width)
import Element.Font as Font
import Element.Input as Input
import Ions.Font as F
import Ions.Size as S
import Palette exposing (accentButton, fillWidth, letterSpacing)
import Screen.Model as Screen

blogView : Screen.Model -> Model -> Element Msg
blogView screen model =
    Element.none