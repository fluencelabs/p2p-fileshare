port module NetworkMap.Port exposing (..)

import NetworkMap.Model exposing (Model, Peer, PeerType(..))
import NetworkMap.Msg exposing (Msg(..))


type alias Command =
    { command : String, id : Maybe String }


type alias Event =
    { event : String, peer: Peer, peerType: String, updateDate: String }

port networkMapReceiver : (Event -> msg) -> Sub msg

stringToPeerType : String -> Maybe PeerType
stringToPeerType str =
    case str of
        "peer" ->
            Just Relay
        "client" ->
            Just Client
        _ ->
            Nothing

eventToMsg : Event -> Msg
eventToMsg event =
    Maybe.withDefault NoOp <|
        case event.event of
            "peer_appeared" ->
                let
                    peerType = stringToPeerType event.peerType
                in
                Maybe.map (\pt -> PeerAppeared event.peer pt event.updateDate) peerType

            _ ->
                Nothing


subscriptions : Model -> Sub Msg
subscriptions _ =
    networkMapReceiver eventToMsg
