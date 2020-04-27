module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Navigation
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Url


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = UrlRequestMsg
        , onUrlChange = UrlChangeMsg
        }


type alias Model =
    Int


type Msg
    = Increment
    | Decrement
    | UrlRequestMsg Browser.UrlRequest
    | UrlChangeMsg Url.Url


type alias Flags =
    Maybe Model


init : Flags -> Url.Url -> Navigation.Key -> ( Model, Cmd msg )
init maybeModel _ _ =
    ( Maybe.withDefault 0 maybeModel, Cmd.none )


update msg model =
    case msg of
        Increment ->
            ( model + 1, Cmd.none )

        Decrement ->
            ( model - 1, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Document Msg
view model =
    let
        body =
            [ button [ onClick Decrement ] [ text "-" ]
            , div [] [ text (String.fromInt model) ]
            , button [ onClick Increment ] [ text "+" ]
            ]
    in
    { title = "Fluence", body = body }
