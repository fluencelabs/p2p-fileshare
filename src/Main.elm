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


type alias Flags =
    Maybe Model


init : Flags -> ( Model, Cmd msg )
init maybeModel =
    ( Maybe.withDefault emptyModel maybeModel, Cmd.none )
