port module NetworkMap.Port exposing (..)

import Maybe exposing (andThen)
import NetworkMap.Model exposing (Model, Peer, PeerType(..))
import NetworkMap.Msg exposing (Msg(..))


type alias Command =
    { command : String, id : Maybe String }


type alias Event =
    { event : String, peerAppeared: Maybe { peer: Peer, peerType: String, updateDate: String } }

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
                event.peerAppeared
                    |> andThen (\peerAppeared -> stringToPeerType peerAppeared.peerType
                    |> andThen (\peerType -> Just (PeerAppeared peerAppeared.peer peerType peerAppeared.updateDate)))
            "show-hide" ->
                Just ShowHide
            _ ->
                Nothing


subscriptions : Model -> Sub Msg
subscriptions _ =
    networkMapReceiver eventToMsg
