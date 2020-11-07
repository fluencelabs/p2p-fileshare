port module Chat.Port exposing (..)

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

import Chat.Model exposing (Message, Model)
import Chat.Msg exposing (Msg(..))


type alias Command =
    { command : String, chatId : Maybe String, name : Maybe String, msg : Maybe String, replyTo : Maybe Int }


type alias Event =
    { event : String, msg : Maybe Message }


port chatRequest : Command -> Cmd msg


port chatReceiver : (Event -> msg) -> Sub msg


eventToMsg : Event -> Msg
eventToMsg event =
    Maybe.withDefault NoOp <|
        case event.event of
            "connected" ->
                Just ConnectedToChat

            "new_msg" ->
                Maybe.map NewMsg event.msg

            _ ->
                Nothing


subscriptions : Model -> Sub Msg
subscriptions _ =
    chatReceiver eventToMsg
