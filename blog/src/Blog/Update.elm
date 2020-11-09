module Blog.Update exposing (..)

import Blog.Model exposing (Model, Post)
import Blog.Msg exposing (Msg(..))
import Blog.Port
import Dict


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
            ( { model | posts = { id = id, text = text, comments = [] } :: model.posts }, Cmd.none )

        NewComment postId name m ->
            let
                newPosts =
                    model.posts |> List.map (updatePost postId name m)
            in
            ( { model | posts = newPosts }, Cmd.none )

        Joined ->
            ( model, Cmd.none )

        Join ->
            ( { model | currentName = "" }
            , Blog.Port.blogRequest
                { command = "join"
                , text = Nothing
                , name = Just model.currentName
                , id = Nothing
                }
            )

        SendPost ->
            ( { model | currentText = "" }
            , Blog.Port.blogRequest
                { command = "send_post"
                , text = Just model.currentText
                , name = Nothing
                , id = Nothing
                }
            )

        SendComment id ->
            let
                text =
                    model.currentCommentsText |> Dict.get id

                newComments =
                    model.currentCommentsText |> Dict.insert id ""
            in
            ( { model | currentCommentsText = newComments, currentName = "" }
            , Blog.Port.blogRequest
                { command = "send_comment"
                , text = text
                , id = Just id
                , name = Just model.currentName
                }
            )

        UpdateName name ->
            ( { model | currentName = name }, Cmd.none )

        UpdateText text ->
            ( { model | currentText = text }, Cmd.none )

        UpdateCommentsText postId text ->
            let
                newComments =
                    Dict.insert postId text model.currentCommentsText
            in
            ( { model | currentCommentsText = newComments }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )
