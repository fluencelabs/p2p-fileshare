port module FilesList.Port exposing (..)

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
