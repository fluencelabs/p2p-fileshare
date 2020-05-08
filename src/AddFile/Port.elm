port module AddFile.Port exposing (..)

import Array exposing (Array)

port calcHash : Array Int -> Cmd msg

port addFileByHash : String -> Cmd msg

port selectFile : () -> Cmd msg
