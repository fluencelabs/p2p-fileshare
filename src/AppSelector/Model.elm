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


type alias Model =
    { currentApp : App
    }


emptyAppSelector : Model
emptyAppSelector =
    { currentApp = None
    }
