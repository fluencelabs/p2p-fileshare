module Chat.View exposing (..)

import Chat.Model exposing (Model)
import Chat.Msg exposing (Msg(..))
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
    Element.none
