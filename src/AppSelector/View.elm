module AppSelector.View exposing (appsList, view)

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



-- Maybe rename to `showSelectedApp` or smth like that?
-- It should not contain any logic, as `msg` types will diverge


view : Screen.Model -> Dict String (Element msg) -> Model -> Element msg
view screen apps model =
    column (layoutBlock screen ++ [ blockBackground, spacing <| S.baseRem 0.75, F.size7 ])
        ([ blockTitle <| text "Select App" ] ++ [ Maybe.withDefault noneApp (Dict.get (appKey model.currentApp) apps) ])


noneApp : Element msg
noneApp =
    text "none"



-- If it needs to be included into the main view, it's better to do it directly


appsList : Screen.Model -> Model -> Element Msg
appsList screen model =
    column []
        [ appButton "File Sharing" FileSharing
        , appButton "Network Map" NetworkMap
        ]


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
