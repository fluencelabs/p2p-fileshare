import {FluenceBlog} from "./fluenceBlog";
import {getApp} from "./ports";

let blog: FluenceBlog | undefined = undefined;

function setBlog(newChat: FluenceBlog) {
    blog = newChat
}

export interface BlogEvent {
    event: string,
    text: string | null,
    name: string | null,
    id: number | null
}

function emptyEvent(event: string): BlogEvent {
    return {event, text: null, name: null, id: null}
}

function createEvent(event: string, text?: string, name?: string, id?: number): BlogEvent {
    if (text === undefined) { text = null }
    if (name === undefined) { name = null }
    if (id === undefined) { id = null }

    return {
        event,
        text,
        name,
        id
    }
}

export function sendEventPost(text: string) {
    sendBlogEvent(createEvent("new_post", text))
}

export function sendEventComment(text: string, name: string, replyTo: number) {
    sendBlogEvent(createEvent("new_comment", text, name, replyTo))
}

export function sendBlogEvent(event: BlogEvent) {
    getApp().ports.blogReceiver.send(event)
}

export function chatHandler(app: any) {
    return async ({command, text, name, id}: {command: string, text?: string, name?: string, id?: number}) => {
        switch (command) {
            case "send_comment":
                if (!text) {
                    console.error("message should be specified on send_comment command")
                    break;
                }

                if (!id) {
                    console.error("id should be specified on send_comment command")
                    break;
                }

                await blog.sendComment(text, id);
                break;
            case "send_post":
                if (!text) {
                    console.error("message should be specified on send_message command")
                    break;
                }

                await blog.sendPost(text);
                break;
        }

    }
}