module Conn.Model exposing (..)


type alias Peer =
    { id : String }


type alias Relay =
    { peer : Peer
    , host : Maybe String
    , dns : Maybe String
    , pport : Int
    }


type alias Model =
    { peer : Peer
    , relay : Maybe Relay
    , discovered : List Relay
    , choosing : Bool
    }


emptyConn : Model
emptyConn =
    { peer = { id = "-----" }
    , relay = Nothing
    , discovered = []
    , choosing = False
    }
