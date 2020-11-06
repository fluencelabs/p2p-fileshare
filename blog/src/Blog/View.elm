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


connectionView : Screen.Model -> Model -> Element Msg
connectionView screen model =
    column []
        [ row [ fillWidth, centerX ]
            [ el [ width (fillPortion 2), letterSpacing, F.gray ] <| Element.text "CHAT ID"
            , Input.text [ width (fillPortion 5) ]
                { onChange = SetChatId
                , text = model.chatId
                , placeholder = Maybe.map (Input.placeholder []) Nothing
                , label = Input.labelHidden "CHAT ID"
                }
            ]
        , row [ fillWidth, centerX ]
            [ el [ width (fillPortion 2), letterSpacing, F.gray ] <| Element.text "NAME"
            , Input.text [ width (fillPortion 5) ]
                { onChange = SetName
                , text = model.name
                , placeholder = Maybe.map (Input.placeholder []) Nothing
                , label = Input.labelHidden "NAME"
                }
            ]
        , row [ fillWidth, centerX ]
            [ Input.button (accentButton ++ [ width (fillPortion 3), paddingXY 0 (S.baseRem 0.5), Font.center ])
                { onPress = Just <| JoinChat
                , label = text "Join chat"
                }
            , el [ width (fillPortion 5) ] none
            ]
        , row [ fillWidth, centerX ]
            [ Input.button (accentButton ++ [ width (fillPortion 3), paddingXY 0 (S.baseRem 0.5), Font.center ])
                { onPress = Just <| CreateChat
                , label = text "Create chat"
                }
            , el [ width (fillPortion 5) ] none
            ]
        ]


talkView : Screen.Model -> Model -> Element Msg
talkView screen model =
    column [] (messageSender model :: messagesView model)


messagesView : Model -> List (Element Msg)
messagesView model =
    model.messages |> List.map (\m -> messageView m.name m.msg)


messageView : String -> String -> Element Msg
messageView name message =
    column []
        [ column []
            [ row [] [ el [ width (fillPortion 2), letterSpacing, Font.bold, F.black ] <| Element.text name ]
            , row [] [ el [ width (fillPortion 2), letterSpacing, F.black ] <| Element.text message ]
            ]
        ]


messageSender : Model -> Element Msg
messageSender model =
    column []
        [ row [ fillWidth, centerX ]
            [ el [ width (fillPortion 2), letterSpacing, F.gray ] <| Element.text "MESSAGE"
            , Input.text [ width (fillPortion 5) ]
                { onChange = SetCurrentMessage
                , text = model.currentMsg
                , placeholder = Maybe.map (Input.placeholder []) Nothing
                , label = Input.labelHidden "MESSAGE"
                }
            ]
        , row [ fillWidth, centerX ]
            [ Input.button (accentButton ++ [ width (fillPortion 3), paddingXY 0 (S.baseRem 0.5), Font.center ])
                { onPress = Just <| SendMessage
                , label = text "Send Message"
                }
            , el [ width (fillPortion 5) ] none
            ]
        ]
