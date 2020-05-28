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
                    { em | connectivity = { initConn | peer = { id = peerId, seed = Nothing } } }

                Nothing ->
                    em
    in
        ( model, initCmd )
