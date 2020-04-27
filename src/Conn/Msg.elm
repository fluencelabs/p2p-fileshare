module Conn.Msg exposing (Msg(..))

import Conn.Model exposing (Peer)


type Msg
    = SetRelay Peer
    | ChoosingRelay Bool
