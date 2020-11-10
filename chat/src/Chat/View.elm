module Chat.View exposing (..)

import Chat.Model exposing (Message, Model)
import Chat.Msg exposing (Msg(..))
import Element exposing (Element, centerX, column, el, fillPortion, mouseOver, none, padding, paddingXY, row, spacing, text, width)
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Ions.Background as BG
import Ions.Border as B
import Ions.Font as F
import Ions.Size as S
import Maybe exposing (map, withDefault)
import Palette exposing (accentButton, fillWidth, letterSpacing)
import Screen.Model as Screen


connectionView : Screen.Model -> Model -> Element Msg
connectionView screen model =
    row [fillWidth] [
        column [width (fillPortion 8), spacing 20] [
            column [ fillWidth, centerX, spacing 10, padding 20, B.width1 B.AllSides, B.blackAlpha 50 ]
                [ row [ fillWidth, centerX ]
                    [ el [ width (fillPortion 1), letterSpacing, F.gray ] <| Element.text "NAME"
                    , Input.text [ width (fillPortion 5) ]
                        { onChange = SetCreateName
                        , text = model.name
                        , placeholder = Maybe.map (Input.placeholder []) Nothing
                        , label = Input.labelHidden "NAME"
                        }
                    , el [ width (fillPortion 5) ] none
                    ]
                , row [ fillWidth, centerX, spacing 10, padding 20 ]
                    [ Input.button (accentButton ++ [ width (fillPortion 3), paddingXY 0 (S.baseRem 0.5), Font.center ])
                        { onPress = Just <| CreateChat
                        , label = text "Create chat"
                        }
                    , el [ width (fillPortion 5) ] none
                    ]
                ]
            , column [ fillWidth, centerX, spacing 10, padding 20, B.width1 B.AllSides, B.blackAlpha 50 ]
                  [ row [ fillWidth, centerX ]
                      [ el [ width (fillPortion 1), letterSpacing, F.gray ] <| Element.text "CHAT ID"
                      , Input.text [ width (fillPortion 5) ]
                          { onChange = SetChatId
                          , text = model.currentChatId
                          , placeholder = Maybe.map (Input.placeholder []) Nothing
                          , label = Input.labelHidden "CHAT ID"
                          }
                      , el [ width (fillPortion 5) ] none
                      ]
                  , row [ fillWidth, centerX ]
                      [ el [ width (fillPortion 1), letterSpacing, F.gray ] <| Element.text "NAME"
                      , Input.text [ width (fillPortion 5) ]
                          { onChange = SetJoinName
                          , text = model.joinName
                          , placeholder = Maybe.map (Input.placeholder []) Nothing
                          , label = Input.labelHidden "NAME"
                          }
                      , el [ width (fillPortion 5) ] none
                      ]
                  , row [ fillWidth, centerX ]
                      [ Input.button (accentButton ++ [ width (fillPortion 3), paddingXY 0 (S.baseRem 0.5), Font.center ])
                          { onPress = Just <| JoinChat
                          , label = text "Join chat"
                          }
                      , el [ width (fillPortion 5) ] none
                      ]
                  ]
        ]
    , el [ width (fillPortion 2) ] none
    ]


talkView : Screen.Model -> Model -> Element Msg
talkView screen model =
    column [] ([] ++ messagesView model ++ [messageSender model])

chatIdView : String -> Element Msg
chatIdView chatId =
    Element.text chatId


messagesView : Model -> List (Element Msg)
messagesView model =
    List.reverse model.messages |> List.map (messageView model)


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
    column [ fillWidth ]
    [ row [ width (fillPortion 2), spacing 10, padding 10 ]
        [ row [ fillWidth, centerX, spacing 10, padding 10 ]
            [ Input.text [ width (fillPortion 5), spacing 10, padding 10 ]
              { onChange = SetCurrentMessage
              , text = model.currentMsg
              , placeholder = Just (Input.placeholder [] (Element.text "Enter a message"))
              , label = Input.labelHidden "MESSAGE"
              }
            , Input.button (accentButton ++ [ width (fillPortion 3), paddingXY 0 (S.baseRem 0.5), Font.center, spacing 10, padding 10 ])
              { onPress = Just <| SendMessage
              , label = text "Send Message"
              }
            ]
        ]
    , el [ width (fillPortion 3) ] none
    ]

