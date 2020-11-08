module Blog.Update exposing (..)

import Blog.Model exposing (Model, Post)
import Blog.Msg exposing (Msg(..))
import Blog.Port

updatePost : Int -> String -> String -> Post -> Post
updatePost postId name msg post =
    if postId == post.id then
        { post | comments = { msg = msg, name = name } :: post.comments }
    else
        post

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewPost id text ->
            ( { model | posts =  { id = id, text = text, comments = [] } :: model.posts }, Cmd.none )

        NewComment postId name m ->
            let
                newPosts = model.posts |> List.map (updatePost postId name m)
            in
                ( { model | posts =  newPosts }, Cmd.none )

        SendPost ->
            ( { model | currentText = "" }
            , Blog.Port.blogRequest
                { command = "send_post"
                , text = Just model.currentText
                , name = Nothing
                , id = Nothing
                } )

        SendComment id ->
            ( { model | currentText = "", currentName = "" }
                , Blog.Port.blogRequest
                    { command = "send_comment"
                    , text = Just model.currentText
                    , id = Just id
                    , name = Just model.currentName
                    } )

        UpdateName name ->
           ( { model | currentName = name }, Cmd.none )

        UpdateText text ->
            ( { model | currentText = text }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

