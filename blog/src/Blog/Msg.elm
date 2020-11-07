module Blog.Msg exposing (..)


type Msg
    = NewPost Int String
    | NewComment Int String String
    | SendPost
    | SendComment Int
    | UpdateName String
    | UpdateText String
    | NoOp
