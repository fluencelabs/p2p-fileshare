module NetworkMap.Msg exposing (Msg(..))

import NetworkMap.Model exposing (Peer, PeerType)

type Msg
    =  PeerAppeared Peer PeerType String
    | NoOp
