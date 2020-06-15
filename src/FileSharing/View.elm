module FileSharing.View exposing (..)

{-| Copyright 2020 Fluence Labs Limited

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

import Element exposing (Element)
import FileSharing.AddFile.View
import FileSharing.FilesList.View
import FileSharing.Model exposing (Model)
import FileSharing.Msg exposing (Msg(..))
import Palette exposing (fillWidth)
import Screen.Model as Screen


view : Screen.Model -> Model -> Element Msg
view screen model =
    Element.column
        [ Element.centerX
        , fillWidth
        ]
        [ Element.map AddFileMsg (FileSharing.AddFile.View.view screen model.addFile)
        , Element.map FilesListMsg (FileSharing.FilesList.View.view screen model.filesList)
        ]
