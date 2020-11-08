port module Blog.Port exposing (..)

{-| Copyright 2020 Fluence Labs Limited

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

import Blog.Model exposing (Model)
import Blog.Msg exposing (Msg(..))


type alias Command =
    { command : String, text : Maybe String, name : Maybe String, id : Maybe Int }


type alias Event =
    { event : String, text : Maybe String, name : Maybe String, id : Maybe Int }


port blogRequest : Command -> Cmd msg


port blogReceiver : (Event -> msg) -> Sub msg


eventToMsg : Event -> Msg
eventToMsg event =
    Maybe.withDefault NoOp <|
        case event.event of
            "new_comment" ->
                Maybe.map3 NewComment event.id event.name event.text

            "new_post" ->
                Maybe.map2 NewPost event.id event.text

            "join" ->
                Maybe.map2 NewPost event.id event.text

            _ ->
                Nothing


subscriptions : Model -> Sub Msg
subscriptions _ =
    blogReceiver eventToMsg
