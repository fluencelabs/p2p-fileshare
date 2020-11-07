module Blog.Model exposing (..)

type alias Comment =
    { msg: String
    , name: String
    }

type alias Post =
    { id: Int
    , text : String
    , comments : List Comment
    }


type alias Model =
    { posts : List Post
    , currentName : String
    , currentText : String
    , isOwner: Bool
    }


emptyBlogModel : Model
emptyBlogModel =
    { posts = [], currentName = "", currentText = "", isOwner = True }
