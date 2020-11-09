module Blog.Msg exposing (..)


type Msg
    = NewPost Int String
    | NewComment Int String String
    | SendPost
    | Join
    | Joined
    | SendComment Int
    | UpdateName String
    | UpdateText String
    | UpdateCommentsText Int String
    | NoOp
