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


type alias Command =
    { command : String, hash : Maybe String }


type alias Event =
    { event : String, hash : String, log : Maybe String, preview: Maybe String }


port fileRequest : Command -> Cmd msg


port fileReceiver : (Event -> msg) -> Sub msg

eventToMsg : Event -> Msg
eventToMsg event =
    Maybe.withDefault NoOp <|
        case event.event of
            "uploading" ->
                Just <| FileUploading event.hash
            "uploaded" ->
                Just <| FileUploaded event.hash
            "downloading" ->
                Just <| FileDownloading event.hash
            "advertised" ->
                Just <| FileAdvertised event.hash event.preview
            "copied" ->
                Just <| Copied event.hash
            "requested" ->
                Just <| FileRequested event.hash

            "loaded" ->
                Just <| FileLoaded event.hash event.preview

            "asked" ->
                Just <| FileAsked event.hash

            "log" ->
                Maybe.map (FileLog event.hash) event.log

            _ ->
                Nothing


subscriptions : Model -> Sub Msg
subscriptions _ =
    fileReceiver eventToMsg
