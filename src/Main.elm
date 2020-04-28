module Main exposing (..)

import Browser exposing (Document)
import Model exposing (Model, emptyModel)
import Update exposing (update)
import View exposing (view)


main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- Should be used to provide keys from some cache


type alias Flags =
    Maybe String


init : Flags -> ( Model, Cmd msg )
init maybeModel =
    ( emptyModel, Cmd.none )
