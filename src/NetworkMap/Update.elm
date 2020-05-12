module NetworkMap.Update exposing (update)

import NetworkMap.Model exposing (Model)
import NetworkMap.Msg exposing (Msg(..))
import NetworkMap.Port


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PeerAppeared peer peerType date ->
            let
                entry =
                    { updateDate = date
                    , peer = peer
                    , peerType = peerType
                    }
                peers = model.network ++ [ entry ]
            in
                ( { model | network = peers }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
