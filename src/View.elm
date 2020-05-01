module View exposing (view)

import AddFile.View
import Browser exposing (Document)
import Conn.View
import Element exposing (Element, column, el, row)
import Element.Events as Events
import Element.Font as Font
import FilesList.View
import Html exposing (Html)
import Model exposing (Model)
import Msg exposing (..)
import Palette exposing (dropdownBg, fillWidth, h1, layout, link, linkColor)


view : Model -> Document Msg
view model =
    { title = title model, body = [ body model ] }


title : Model -> String
title _ =
    "Fluence p2p filesharing demo app"


body : Model -> Html Msg
body model =
    layout <| List.concat [ header, connectivity model, addFile model, filesList model ]


liftView :
    (Model -> model)
    -> (msg -> Msg)
    -> (model -> List (Element msg))
    -> (Model -> List (Element Msg))
liftView getModel liftMsg subView =
    \model ->
        let
            subModel =
                getModel model

            res =
                subView subModel

            liftInEl =
                Element.map liftMsg
        in
        List.map liftInEl res


header : List (Element Msg)
header =
    [ row
        [ Element.centerX ]
        [ h1 "Fluence demo" ]
    , row
        [ Element.centerX ]
        [ el [ Font.italic ] <| Element.text "Fluence-powered client-to-client file sharing via IPFS" ]
    , row
        [ Element.width Element.fill ]
        [ Element.textColumn [ Element.width <| Element.fillPortion 5 ] [ Element.text "Long description" ]
        , column [ Element.width <| Element.fillPortion 1 ]
            [ link "https://fluence.network" "Whitepaper"
            , link "https://fluence.network" "Deep dive"
            ]
        ]
    ]


connectivity : Model -> List (Element Msg)
connectivity model =
    liftView .connectivity ConnMsg Conn.View.view <| model


addFile : Model -> List (Element Msg)
addFile model =
    liftView .addFile AddFileMsg AddFile.View.view <| model


filesList : Model -> List (Element Msg)
filesList model =
    liftView .filesList FilesListMsg FilesList.View.view <| model
