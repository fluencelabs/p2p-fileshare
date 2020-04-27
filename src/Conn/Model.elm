module Conn.Model exposing (..)


type alias Peer =
    { id : String }


type alias Model =
    { peer : Peer
    , relay : Maybe Peer
    , discovered : List Peer
    , choosing : Bool
    }


emptyConn : Model
emptyConn =
    { peer = { id = "SomePeerId" }
    , relay = Just { id = "SomeRelayId" }
    , discovered = [ { id = "SomeRelayId" }, { id = "SomeRelayId2" }, { id = "SomeRelayId3" }, { id = "SomeRelayId4" }, { id = "SomeRelayId5" } ]
    , choosing = False
    }
