module NetworkMap.Model exposing (..)


type PeerType
    = Relay
    | Client

type alias Peer =
    { id : String }

type alias NodeEntry =
    { updateDate: String
    , peer: Peer
    , peerType: PeerType
    }

type alias Model =
    { network : List NodeEntry
    }


emptyNetwork : Model
emptyNetwork =
    { network = []
    }
