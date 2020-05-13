module NetworkMap.Model exposing (..)


import Dict exposing (Dict)
type PeerType
    = Relay
    | Client

type alias Peer =
    { id : String }

type alias NodeEntry =
    { peer: Peer
    , peerType: PeerType
    , date: String
    }

type alias Model =
    { network : Dict String NodeEntry
    }


emptyNetwork : Model
emptyNetwork =
    { network = Dict.empty
    }
