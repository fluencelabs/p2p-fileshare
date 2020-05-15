module NetworkMap.Update exposing (update)

import Dict
import NetworkMap.Model exposing (Model)
import NetworkMap.Msg exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PeerAppeared peer peerType date ->
            let
                entry =
                    { peer = peer
                    , peerType = peerType
                    , date = date
                    }
                peers = Dict.insert entry.peer.id entry model.network
            in
                ( { model | network = peers }, Cmd.none )
        ShowHide ->
            ( { model | show = not model.show }, Cmd.none )
        NoOp ->
            ( model, Cmd.none )
