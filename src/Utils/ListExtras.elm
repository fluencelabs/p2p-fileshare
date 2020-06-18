module Utils.ListExtras exposing (..)

import List exposing (filter, head)
import Utils.MaybeExtras exposing (nonEmpty)

find : (a -> Bool) -> List a -> Maybe a
find f l = l |> filter f |> head

contains : (a -> Bool) -> List a -> Bool
contains f l = nonEmpty (find f l)