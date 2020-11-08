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


sendView : Model -> Bool -> Element Msg
sendView model isOwner =
    case isOwner of
        True ->
            ownerSendView model

        False ->
            visitorSendView model


ownerSendView : Model -> Element Msg
ownerSendView model =
    column []
        [ row [ fillWidth, centerX ]
            [ el [ width (fillPortion 2), letterSpacing, F.gray ] <| Element.text "POST"
            , Input.multiline [ width (fillPortion 5) ]
                { onChange = UpdateText
                , text = model.currentText
                , placeholder = Maybe.map (Input.placeholder []) Nothing
                , label = Input.labelHidden "POST"
                , spellcheck = False
                }
            ]
        , row [ fillWidth, centerX ]
            [ Input.button (accentButton ++ [ width (fillPortion 3), paddingXY 0 (S.baseRem 0.5), Font.center ])
                { onPress = Just <| SendPost
                , label = text "Send Post"
                }
            , el [ width (fillPortion 5) ] none
            ]
        ]


visitorSendView : Model -> Element Msg
visitorSendView model =
    column []
        [ row [ fillWidth, centerX ]
            [ el [ width (fillPortion 2), letterSpacing, F.gray ] <| Element.text "COMMENT"
            , Input.text [ width (fillPortion 5) ]
                { onChange = UpdateText
                , text = model.currentText
                , placeholder = Maybe.map (Input.placeholder []) Nothing
                , label = Input.labelHidden "COMMENT"
                }
            ]
        , row [ fillWidth, centerX ]
            [ Input.button (accentButton ++ [ width (fillPortion 3), paddingXY 0 (S.baseRem 0.5), Font.center ])
                { onPress = Just <| SendPost
                , label = text "Send Comment"
                }
            , el [ width (fillPortion 5) ] none
            ]
        ]


commentsView : List Comment -> Element Msg
commentsView comments =
    column []
        (comments |> List.map commentView)


commentView : Comment -> Element Msg
commentView comment =
    column [ paddingXY 7 10, fillWidth ]
        [ row [] [ el [ width (fillPortion 2), letterSpacing, Font.bold, F.black ] <| Element.text comment.name ]
        , row [] [ el [ width (fillPortion 2), letterSpacing, F.black ] <| Element.text comment.msg ]
        ]


joinView : Model -> Element Msg
joinView model =
    column []
        [ row [ fillWidth, centerX ]
            [ el [ width (fillPortion 2), letterSpacing, F.gray ] <| Element.text "NAME"
            , Input.text [ width (fillPortion 5) ]
                { onChange = UpdateName
                , text = model.currentName
                , placeholder = Maybe.map (Input.placeholder []) Nothing
                , label = Input.labelHidden "NAME"
                }
            ]
        , row [ fillWidth, centerX ]
            [ Input.button (accentButton ++ [ width (fillPortion 3), paddingXY 0 (S.baseRem 0.5), Font.center ])
                { onPress = Just <| Join
                , label = text "JOIN"
                }
            , el [ width (fillPortion 5) ] none
            ]
        ]
