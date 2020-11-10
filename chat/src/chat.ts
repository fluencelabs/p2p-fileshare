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

function getChat() {
    return chat
}

export interface ChatEvent {
    event: string,
    msg: ElmMessage | null,
    id: string | null
}

function emptyEvent(event: string): ChatEvent {
    return {event, msg: null, id: null}
}

function createEvent(event: string, msg?: ElmMessage, id?: string): ChatEvent {
    if (msg === undefined) { msg = null }
    if (id === undefined) { id = null }

    return {
        event,
        msg,
        id
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
                let chat = await joinChat(name, chatId, peerIdToSeed(pid), relay.multiaddr)

                setChat(chat)
                sendChatEvent(createEvent("connected", undefined, chat.chatId))
                break;
            case "create":
                if (!name) {
                    console.error("name should be specified on create command")
                    break;
                }

                let chat1 = await createChat(name, peerIdToSeed(await Fluence.generatePeerId()), randomRelay().multiaddr)
                setChat(chat1)

                sendChatEvent(createEvent("connected", undefined, chat1.chatId))

                break;
            case "send_message":
                if (!msg) {
                    console.error("message should be specified on send_message command")
                    break;
                }

                if (!replyTo) {
                    replyTo = 0
                }

                await getChat().sendMessage(msg, replyTo);
                break;
        }

    }
}