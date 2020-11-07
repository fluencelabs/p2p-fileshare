module Chat.View exposing (..)

import Chat.Model exposing (Message, Model)
import Chat.Msg exposing (Msg(..))
import Element exposing (Element, centerX, column, el, fillPortion, mouseOver, none, paddingXY, row, text, width)
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Ions.Background as BG
import Ions.Font as F
import Ions.Size as S
import Maybe exposing (map, withDefault)
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
    model.messages |> List.map (messageView model)


replyView : List Message -> Int -> Element Msg
replyView messages replyToId =
    let
        replyToMessage =
            messages |> List.filter (\m -> m.id == replyToId) |> List.head
    in
    case replyToMessage of
        Just message ->
            column []
                [ column []
                    [ row [] [ el [ width (fillPortion 2), letterSpacing, Font.bold, F.gray ] <| Element.text ("| " ++ message.name) ]
                    , row [] [ el [ width (fillPortion 2), letterSpacing, F.gray ] <| Element.text ("| " ++ message.msg) ]
                    ]
                ]

        Nothing ->
            Element.none


messageView : Model -> Message -> Element Msg
messageView model message =
    let
        repliedTo =
            case message.replyTo of
                Just replyToId ->
                    replyView model.messages replyToId

                Nothing ->
                    Element.none

        selected =
            model.replyTo |> map (\r -> r == message.id) |> withDefault False

        replyToEvent =
            if selected then
                [ Events.onClick (SetReplyTo Nothing), BG.washedRed, Element.pointer ]

            else if message.id == 0 then
                []

            else
                [ Events.onClick (SetReplyTo (Just message.id)), mouseOver [ BG.washedRed ], Element.pointer ]
    in
    column []
        [ column (replyToEvent ++ [ paddingXY 7 10, fillWidth ])
            [ repliedTo
            , row [] [ el [ width (fillPortion 2), letterSpacing, Font.bold, F.black ] <| Element.text message.name ]
            , row [] [ el [ width (fillPortion 2), letterSpacing, F.black ] <| Element.text message.msg ]
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
