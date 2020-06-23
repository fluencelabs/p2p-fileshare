module AppSelector.Model exposing (..)

type App
    = FileSharing
    | NetworkMap
    | None

appKey : App -> String
appKey app =
    case app of
        FileSharing ->
            "FileSharing"

        NetworkMap ->
            "NetworkMap"

        None ->
            "None"

stringToApp : String -> App
stringToApp key =
    case key of
        "FileSharing" ->
            FileSharing

        "NetworkMap" ->
            NetworkMap

        _ -> None




type alias Model =
    { currentApp : App
    }

emptyAppSelector : Model
emptyAppSelector =
    { currentApp = None
    }