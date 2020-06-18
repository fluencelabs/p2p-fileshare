module Utils.ArrayExtras exposing (..)

import Array exposing (Array, empty, filter, foldl, fromList, get, push, toList)
import Utils.MaybeExtras exposing (nonEmpty)

find : (a -> Bool) -> Array a -> Maybe a
find f l = l |> filter f |> get 0

contains : (a -> Bool) -> Array a -> Bool
contains f l = nonEmpty (find f l)

reverse : Array a -> Array a
reverse ar =
  fromList (List.reverse (toList ar))