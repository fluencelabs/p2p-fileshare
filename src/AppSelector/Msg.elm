module AppSelector.Msg exposing (..)

import AppSelector.Model exposing (App)

type Msg
    = ChooseApp App
    | NoOp