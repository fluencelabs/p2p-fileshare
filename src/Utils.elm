module Utils exposing (..)

import Task

run : msg -> Cmd msg
run m =
    Task.perform (always m) (Task.succeed ())