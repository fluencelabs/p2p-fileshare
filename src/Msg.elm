module Msg exposing (Msg(..))

import Model exposing (Peer)


type Msg
    = NoOp
    | SetRelay Peer
    | ChoosingRelay Bool
