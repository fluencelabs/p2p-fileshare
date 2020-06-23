module AppSelector.Model exposing (..)

type App
    = FileSharing
    | NetworkMap
    | None

appKey : App -> String
appKey app =
    case app of
        FileSharing ->
            "File Sharing"

        NetworkMap ->
            "Network Map"

        None ->
            "None"

stringToApp : String -> App
stringToApp key =
    case key of
        "File Sharing" ->
            FileSharing

        "Network Map" ->
            NetworkMap

        _ -> None




type alias Model =
    { currentApp : App
    }

emptyAppSelector : Model
emptyAppSelector =
    { currentApp = None
    }