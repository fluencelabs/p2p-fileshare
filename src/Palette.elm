module Palette exposing (..)

{-|
  Copyright 2020 Fluence Labs Limited

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-}

import Element exposing (Element, el)
import Element.Font as Font
import Element.Region as Region
import Html exposing (Html)
import Ions.Background as BG
import Ions.Border as B
import Ions.Color as C
import Ions.Font as F
import Ions.Size as S
import Screen.Model exposing (isNarrow)


accentFontColor =
    F.darkRed


letterSpacing =
    Font.letterSpacing 1.7


accentButton =
    [ F.white, BG.darkRed ]


blockBackground =
    BG.nearWhite


blockTitle inside =
    el [ fillWidth, accentFontColor, letterSpacing, Font.bold, Element.paddingXY 0 <| S.baseRem 1 ] <| inside


link : String -> String -> Element msg
link url label =
    Element.link
        linkStyle
        { url = url, label = Element.text label }

newTabLink : String -> String -> Element msg
newTabLink url label =
    Element.newTabLink
        linkStyle
        { url = url, label = Element.text label }


linkStyle =
    [ accentFontColor, C.easeIn, Font.underline ]


h1 txt =
    el
        [ Region.heading 1
        , F.size2
        , Font.semiBold
        , Element.paddingXY 0 (S.baseRem 0.67)
        , F.code
        , accentFontColor
        ]
    <|
        Element.text txt


fillWidth =
    Element.width Element.fill


limitLayoutWidth =
    Element.width (Element.fill |> Element.maximum (S.baseRem 64))


layoutBlock screen =
    [ Element.centerX, limitLayoutWidth, Element.paddingXY (S.baseRem (if (isNarrow screen) then 2 else 4)) (S.baseRem 1) ]


pSpacing =
    Element.spacing <| S.baseRem 0.5

shortHashRaw size hash =
    String.concat
        [ String.left size hash
        , "..."
        , String.right (size - 1) hash
        ]

shortHashEl size hash =
    let
        sh = shortHashRaw size hash
    in
    Element.el
        [ B.nearBlack
        , F.code
        ]
    <|
        Element.text sh

shortHash hash =
    shortHashEl 6 hash

mediumHash hash =
    shortHashEl 12 hash

showHash hash =
    Element.el
        [ B.nearBlack
        , F.code
        ]
    <|
        Element.text (hash)


layout : List (Element msg) -> Html msg
layout elms =
    Element.layout
        [ F.size6
        , F.sansSerif
        , Element.padding (S.baseRem 1)
        ]
    <|
        Element.column
            [ Element.centerX
            , fillWidth
            ]
            elms
