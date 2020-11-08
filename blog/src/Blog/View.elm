module Blog.View exposing (..)

import Blog.Model exposing (Comment, Model, Post)
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
    column []
        (model.posts |> List.map postView)

postView : Post -> Element Msg
postView post =
    column []
        [ Element.text post.text
        , commentsView post.comments
        ]

commentsView : List Comment -> Element Msg
commentsView comments =
    column []
        (comments |> List.map commentView)

commentView : Comment -> Element Msg
commentView comment =
    column ([ paddingXY 7 10, fillWidth ])
                [ row [] [ el [ width (fillPortion 2), letterSpacing, Font.bold, F.black ] <| Element.text comment.name ]
                , row [] [ el [ width (fillPortion 2), letterSpacing, F.black ] <| Element.text comment.msg ]
                ]