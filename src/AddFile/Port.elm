port module AddFile.Port exposing (..)

import AddFile.Model exposing (Model)
import AddFile.Msg exposing (Msg(..))
import Array exposing (Array)
import Bytes exposing (Bytes)
import Bytes.Decode


bytesToArray : Bytes -> Array Int
bytesToArray bytes =
    let
        listStep decoder ( n, xs ) =
            if n <= 0 then
                Bytes.Decode.succeed (Bytes.Decode.Done xs)

            else
                Bytes.Decode.map (\x -> Bytes.Decode.Loop ( n - 1, Array.append xs <| Array.repeat 1 x )) decoder

        bytesListDecode decoder len =
            Bytes.Decode.loop ( len, Array.empty ) (listStep decoder)

        listDecode =
            bytesListDecode Bytes.Decode.unsignedInt8 (Bytes.width bytes)
    in
    Maybe.withDefault Array.empty (Bytes.Decode.decode listDecode bytes)


calcHashBytes : Bytes -> Cmd msg
calcHashBytes =
    calcHash << bytesToArray


port calcHash : Array Int -> Cmd msg


port addFileByHash : String -> Cmd msg


port hashReceiver : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    hashReceiver FileHashReceived
