port module FilesList.Port exposing (..)

import FilesList.Model exposing (Model, Status(..))
import FilesList.Msg exposing (Msg(..))


type alias Command =
    { command : String, hash : Maybe String }


type alias Event =
    { event : String, hash : String, log : Maybe String, preview: Maybe String, status: Maybe String }


port fileRequest : Command -> Cmd msg


port fileReceiver : (Event -> msg) -> Sub msg

stringToStatus : String -> Maybe Status
stringToStatus statusString =
    case statusString of
        "prepared" ->
            Just Prepared
        "advertised" ->
            Just Advertised
        "requested" ->
            Just Requested
        "uploading" ->
            Just Uploading
        "downloading" ->
            Just Downloading
        _ ->
            Nothing


eventToMsg : Event -> Msg
eventToMsg event =
    Maybe.withDefault NoOp <|
        case event.event of
            "file-uploading" ->
                Just <| FileUploading event.hash
            "file-uploaded" ->
                Just <| FileUploaded event.hash
            "file-downloading" ->
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
