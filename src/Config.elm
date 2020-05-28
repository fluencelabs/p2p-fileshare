module Config exposing (..)

-- Should be used to provide keys from some cache
import Conn.Relay exposing (RelayInput)
type alias Config =
    { peerId : Maybe String, isAdmin : Bool, defaultPeerRelayInput: RelayInput }


type alias Flags =
    Maybe Config