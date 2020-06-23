module AppSelector.View exposing (..)

import AppSelector.Model exposing (App(..), Model, appKey, stringToApp)
import AppSelector.Msg exposing (Msg(..))
import Dict exposing (Dict)
import Element exposing (Element, column, spacing, text, width)
import Element.Font as Font
import Element.Input as Input
import Ions.Font as F
import Ions.Size as S
import Palette exposing (blockBackground, blockTitle, layoutBlock)
import Screen.Model as Screen

view : Screen.Model -> Dict String (Element msg) -> Model -> Element msg
view screen apps model =
    column (layoutBlock screen ++ [ blockBackground, spacing <| S.baseRem 0.75, F.size7 ])
            ([ blockTitle <| text "Select App" ] ++ appsList ++ [Maybe.withDefault noneApp (Dict.get (appKey model.currentApp) apps)])

noneApp : Element msg
noneApp =
    text "none"

appsList : List (Element Msg)
appsList = [ appButton "File Sharing" FileSharing
           , appButton "Network Map" NetworkMap
            ]

appButton : String -> App -> Element Msg
appButton name app = Input.button
                [ width <| Element.px 80 ]
            <|
                { onPress = Just <| ChooseApp app
                , label =
                    Element.el
                        [ Font.underline
                        ]
                        (Element.text name)
                }