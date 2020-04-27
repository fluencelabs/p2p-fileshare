module Model exposing (Connectivity, Model, Peer, emptyModel)


type alias Model =
    { connectivity : Connectivity }


type alias Peer =
    { id : String }


type alias Connectivity =
    { peer : Peer
    , relay : Maybe Peer
    , discovered : List Peer
    , choosing : Bool
    }


emptyModel : Model
emptyModel =
    { connectivity =
        { peer = { id = "SomePeerId" }
        , relay = Just { id = "SomeRelayId" }
        , discovered = [ { id = "SomeRelayId" }, { id = "SomeRelayId2" }, { id = "SomeRelayId3" }, { id = "SomeRelayId4" }, { id = "SomeRelayId5" } ]
        , choosing = False
        }
    }
