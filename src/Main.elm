module Main exposing (..)

import Browser exposing (Document)
import Model exposing (Model, emptyModel)
import Subscriptions exposing (subscriptions)
import Update exposing (update)
import View exposing (view)


main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- Should be used to provide keys from some cache


type alias Config =
    { peerId : String }


type alias Flags =
    Maybe Config


init : Flags -> ( Model, Cmd msg )
init maybeFlags =
    let
        em =
            emptyModel

        initConn =
            em.connectivity

        model =
            case maybeFlags of
                Just { peerId } ->
                    { em | connectivity = { initConn | peer = { id = peerId } } }

                Nothing ->
                    em
    in
    ( model, Cmd.none )
