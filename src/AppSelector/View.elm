module AppSelector.View exposing (showAppsList, showSelectedApp)

import AppSelector.Model exposing (App(..), Model, appKey)
import AppSelector.Msg exposing (Msg(..))
import Dict exposing (Dict)
import Element exposing (Element, column, spacing, text, width)
import Element.Font as Font
import Element.Input as Input
import Ions.Font as F
import Ions.Size as S
import Palette exposing (blockBackground, blockTitle, layoutBlock)
import Screen.Model as Screen


showSelectedApp : Screen.Model -> Dict String (Element msg) -> Model -> Element msg
showSelectedApp screen apps model =
    case (Dict.get (appKey model.currentApp) apps) of
        Just app ->
            column (layoutBlock screen ++ [ blockBackground, spacing <| S.baseRem 0.75, F.size7 ])
                    ([ blockTitle <| text (appKey model.currentApp) ] ++ [ app ])

        Nothing ->
            Element.none


showAppsList : Screen.Model -> Model -> Element Msg
showAppsList screen model =
    column (layoutBlock screen ++ [ blockBackground, spacing <| S.baseRem 0.75, F.size7 ])
            ([ blockTitle <| text "SELECT APP" ] ++
        [ appButton "File Sharing" FileSharing
        , appButton "Network Map" NetworkMap
        ])


appButton : String -> App -> Element Msg
appButton name app =
    Input.button
        [ width <| Element.px 80 ]
    <|
        { onPress = Just <| ChooseApp app
        , label =
            Element.el
                [ Font.underline
                ]
                (Element.text name)
        }
