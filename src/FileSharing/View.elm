module FileSharing.View exposing (..)

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
