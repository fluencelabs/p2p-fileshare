import {ElmMessage, FluenceChat} from "./fluenceChat";
import {createChat, joinChat} from "./globalFunctions";
import {peerIdToSeed} from "fluence/dist/seed";
import {getApp} from "./ports";
import {randomRelay} from "./main";
import Fluence from "fluence";

let chat: FluenceChat | undefined = undefined;

function setChat(newChat: FluenceChat) {
    chat = newChat
}

export interface ChatEvent {
    event: string,
    msg: ElmMessage | null
}

function emptyEvent(event: string): ChatEvent {
    return {event, msg: null}
}

function createEvent(event: string, msg?: ElmMessage): ChatEvent {
    if (msg === undefined) { msg = null }

    return {
        event,
        msg
    }
}

export function sendEventMessage(msg: ElmMessage) {
    getApp().ports.chatReceiver.send(createEvent("new_msg", msg))
}

export function sendChatEvent(event: ChatEvent) {
    getApp().ports.chatReceiver.send(event)
}

export function chatHandler(app: any) {
    return async ({command, chatId, name, msg, replyTo}:
                      {command: string, chatId?: string, name?: string, msg?: string, replyTo?: number}) => {
        switch (command) {
            case "join":
                if (!chatId) {
                    console.error("chatId should be specified on join command")
                    break;
                }

                if (!name) {
                    console.error("name should be specified on join command")
                    break;
                }

                let relay = randomRelay()
                let pid = await Fluence.generatePeerId()

                setChat(await joinChat(name, chatId, peerIdToSeed(pid), relay.multiaddr))
                sendChatEvent(emptyEvent("connected"))
                break;
            case "create":
                if (!name) {
                    console.error("name should be specified on create command")
                    break;
                }

                setChat(await createChat(name, peerIdToSeed(await Fluence.generatePeerId()), randomRelay().multiaddr))

                sendChatEvent(emptyEvent("connected"))

                break;
            case "send_message":
                if (!msg) {
                    console.error("message should be specified on send_message command")
                    break;
                }

                if (!replyTo) {
                    replyTo = 0
                }

                await chat.sendMessage(msg, replyTo);
                break;
        }

    }
}