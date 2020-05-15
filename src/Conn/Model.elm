module Conn.Model exposing (..)


type alias Peer =
    { id : String }


type alias Relay =
    { peer : Peer
    , host : Maybe String
    , dns : Maybe String
    , pport : Int
    }

type Status
    = NotConnected
    | Connecting
    | Connected

type alias Model =
    { peer : Peer
    , relay : Maybe Relay
    , status: Status
    , discovered : List Relay
    , choosing : Bool
    }


emptyConn : Model
emptyConn =
    { peer = { id = "-----" }
    , relay = Nothing
    , status = NotConnected
    , discovered = []
    , choosing = False
    }
