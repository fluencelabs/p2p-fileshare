module Main exposing (..)

import Browser exposing (Document, UrlRequest)
import Model exposing (Model, emptyModel)
import Msg exposing (Msg(..))
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
    { peerId : Maybe String, isAdmin : Bool }


type alias Flags =
    Maybe Config


init : Flags -> ( Model, Cmd Msg )
init maybeFlags =
    let
        (em, initCmd) =
            emptyModel <| Maybe.withDefault False (Maybe.map (\f -> f.isAdmin) maybeFlags)

        initConn =
            em.connectivity

        _ = Maybe.andThen

        initPeerId = Maybe.andThen (\f -> f.peerId) maybeFlags

        model =
            case initPeerId of
                Just peerId ->
                    { em | connectivity = { initConn | peer = { id = peerId } } }

                Nothing ->
                    em
    in
        ( model, initCmd )
