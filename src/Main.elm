module Main exposing (..)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Navigation
import Conn.Msg
import Model exposing (Model, emptyModel)
import Msg exposing (Msg(..))
import Subscriptions exposing (subscriptions)
import Task
import Update exposing (update)
import Url
import View exposing (view)


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }

onUrlRequest : UrlRequest -> Msg
onUrlRequest url =
    Msg.UrlChanged

onUrlChange : Url.Url -> Msg
onUrlChange url =
    Msg.UrlChanged

-- Should be used to provide keys from some cache


type alias Config =
    { peerId : String }


type alias Flags =
    Maybe Config


init : Flags -> Url.Url -> Navigation.Key -> ( Model, Cmd Msg )
init maybeFlags url key =
    let
        em =
            emptyModel

        initConn =
            em.connectivity

        admin = url.path == "/admin"

        model =
            case maybeFlags of
                Just { peerId } ->
                    { em | connectivity = { initConn | peer = { id = peerId } } }

                Nothing ->
                    em
        _ = Debug.log "admin" (Debug.toString admin)
    in
    if (admin) then
        ( model, Cmd.none )
    else ( model, Cmd.batch [ run <| ConnMsg Conn.Msg.GeneratePeer ] )

run : Msg -> Cmd Msg
run m =
    Task.perform (always m) (Task.succeed ())
