module Screen.Msg exposing (..)

import Element exposing (Device)


type Msg
    = NoOp
    | WindowResized Device Int Int
