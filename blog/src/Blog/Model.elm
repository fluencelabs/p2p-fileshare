module Blog.Model exposing (..)

import Dict exposing (Dict)


type alias Comment =
    { msg : String
    , name : String
    }


type alias Post =
    { id : Int
    , text : String
    , comments : List Comment
    }


type alias Model =
    { posts : List Post
    , currentName : String
    , currentText : String
    , currentCommentsText : Dict Int String
    , isOwner : Bool
    }


emptyBlogModel : Bool -> Model
emptyBlogModel owner =
    { posts = [], currentName = "", currentText = "", isOwner = owner, currentCommentsText = Dict.empty }
