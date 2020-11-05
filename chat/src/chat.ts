import {FluenceChat} from "./fluenceChat";
import {createChat, joinChat} from "./globalFunctions";
import {getPeerId, getRelayMultiaddr} from "./connection";
import {peerIdToSeed} from "fluence/dist/seed";

let chat: FluenceChat | undefined = undefined;

function setChat(newChat: FluenceChat) {
    chat = newChat
}

interface ChatEvent {
    event: string,
    msg: string | null,
    name: string | null,
    relay: string | null
}

function emptyEvent(event: string): ChatEvent {
    return {event, msg: null, name: null, relay: null}
}

export function chatHandler(app: any) {
    return async ({command, chatId, name}: {command: string, chatId?: string, name?: string}) => {
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

                setChat(await joinChat(name, chatId, peerIdToSeed(getPeerId()), getRelayMultiaddr()))
                app.ports.chatReceiver.send(emptyEvent("connected"))
                break;
            case "create":
                if (!name) {
                    console.error("name should be specified on create command")
                    break;
                }

                setChat(await createChat(name, peerIdToSeed(getPeerId()), getRelayMultiaddr()))
                app.ports.chatReceiver.send(emptyEvent("connected"))
                break;
        }

    }
}