port module FilesList.Port exposing (..)

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

import FilesList.Model exposing (Model, Status(..))
import FilesList.Msg exposing (Msg(..))
import Maybe exposing (andThen)


type alias Command =
    { command : String, hash : Maybe String }


type alias Event =
    { event : String, hash : Maybe String, log : Maybe String, preview: Maybe String }


port fileRequest : Command -> Cmd msg


port fileReceiver : (Event -> msg) -> Sub msg

zip : Maybe a -> Maybe b -> Maybe (a, b)
zip xs ys =
  Maybe.map2 Tuple.pair xs ys

eventToMsg : Event -> Msg
eventToMsg event =
    Maybe.withDefault NoOp <|
        case event.event of
            "uploading" ->
                Maybe.map (FileUploading) event.hash
            "uploaded" ->
                Maybe.map (FileUploaded) event.hash
            "downloading" ->
                Maybe.map (FileDownloading) event.hash
            "advertised" ->
                Maybe.map (\m -> m event.preview) (Maybe.map (FileAdvertised) event.hash)
            "copied" ->
                Maybe.map (Copied) event.hash
            "requested" ->
                Maybe.map (FileRequested) event.hash
            "reset_entries" ->
                Just <| ResetEntries

            "loaded" ->
                Maybe.map (\m -> m event.preview) (Maybe.map (FileLoaded) event.hash)
            "asked" ->
                Maybe.map (FileAsked) event.hash

            "log" ->
                event.hash
                    |> andThen (\h -> event.log
                    |> andThen (\l -> Just (FileLog h l) ))

            _ ->
                Nothing


subscriptions : Model -> Sub Msg
subscriptions _ =
    fileReceiver eventToMsg
