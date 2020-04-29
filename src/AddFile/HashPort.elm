port module AddFile.HashPort exposing (..)

import AddFile.Model exposing (Model)
import AddFile.Msg exposing (Msg(..))
import Bytes exposing (Bytes)
import Bytes.Decode
import Bytes.Encode exposing (..)
import File exposing (File)


calcHashBytes : Bytes -> Cmd msg
calcHashBytes bytes =
    let
        listStep decoder ( n, xs ) =
            if n <= 0 then
                Bytes.Decode.succeed (Bytes.Decode.Done xs)

            else
                Bytes.Decode.map (\x -> Bytes.Decode.Loop ( n - 1, x :: xs )) decoder

        bytesListDecode decoder len =
            Bytes.Decode.loop ( len, [] ) (listStep decoder)

        listDecode =
            bytesListDecode Bytes.Decode.unsignedInt8 (Bytes.width bytes)
    in
    calcHash <| Maybe.withDefault [] (Bytes.Decode.decode listDecode bytes)


port calcHash : List Int -> Cmd msg


port hashReceiver : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions _ =
    hashReceiver FileHashReceived
