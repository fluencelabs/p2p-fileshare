import {FluenceClient} from "fluence/dist/fluenceClient";
import {registerService} from "fluence/dist/globalState";
import {Service} from "fluence/dist/service";
import {build} from "fluence/dist/particle";
import {CHAT_PEER_ID} from "./main";
import {sendEventMessage} from "./chat";

export const HISTORY_NAME = "history"
export const USER_LIST_NAME = "user-list"

export interface Member {
    clientId: string,
    relay: string,
    sig: string,
    name: string
}

export interface Message {
    author: string,
    body: string,
    id: number,
    reply_to: number
}

export interface ElmMessage {
    msg: string,
    name: string,
    id: number,
    replyTo: number
}


export class FluenceChat {
    client: FluenceClient
    historyId: string
    userListId: string
    chatId: string
    name: string
    relay: string
    chatPeerId: string
    members: Member[]

    constructor(client: FluenceClient, chatId: string, historyId: string, userListId: string, peerId: string, name: string, relay: string) {
        this.client = client;
        this.name = name;
        this.historyId = historyId;
        this.userListId = userListId;
        this.members = [];
        this.relay = relay;
        this.chatPeerId = peerId;
        this.chatId = chatId;

        // register service with function that will handle incoming messages from a chat
        let service = new Service(this.chatId)
        service.registerFunction("join", (args: any[]) => {
            let member: Member;
            if (typeof args[0] !== 'object') {
                member = {
                    clientId: args[0],
                    relay: args[1],
                    sig: args[2],
                    name: args[3]
                }
            } else {
                let m = args[0]
                member = {
                    clientId: m.peer_id,
                    relay: m.relay_id,
                    sig: m.signature,
                    name: m.name
                }
            }
            this.addMember(member);
            return {}
        })

        service.registerFunction("all_msgs", (args: any[]) => {
            args[0].forEach((v: Message) => {
                console.log("all msgs:")
                console.log(v)
                let name;
                if (v.author === this.client.selfPeerIdStr) {
                    name = "Me"
                } else {
                    name = this.members.find(m => m.clientId === v.author)?.name
                }
                let replyTo;
                if (v.reply_to) {
                    replyTo = v.reply_to
                } else {
                    replyTo = null;
                }
                if (name) {
                    FluenceChat.notifyNewMessage({name: decodeURIComponent(name), msg: v.body, id: v.id, replyTo})
                }
            })

            return {}
        })

        service.registerFunction("user_deleted", (args: any[]) => {
            console.log("Member deleted: " + args[0])
            this.deleteMember(args[0]);
            return {}
        })

        service.registerFunction("add", (args: any[]) => {
            console.log("msg:")
            console.log(args)
            let [id, pid, msg, replyTo] = args
            let m = this.members.find(m => m.clientId === pid)

            if (replyTo === 0) {
                replyTo = null;
            }
            if (m) {
                FluenceChat.notifyNewMessage({name: m.name, msg: msg as string, id: id, replyTo})
            } else if (args[1] === this.client.selfPeerIdStr) {
                FluenceChat.notifyNewMessage({name: "Me", msg: msg, id, replyTo})
            }
            return {}
        })

        registerService(service)
    }

    /**
     * Call 'join' service and send notifications to all members.
     */
    async join() {
        let script = this.genScript(this.userListId, "join", ["user", "relay", "sig", "name"])

        let data = new Map()
        data.set("user", this.client.selfPeerIdStr)
        data.set("relay", this.client.connection.nodePeerId.toB58String())
        data.set("sig", this.client.selfPeerIdStr)
        data.set("name", encodeURIComponent(this.name))

        let particle = await build(this.client.selfPeerId, script, data, 600000)
        await this.client.sendParticle(particle)
    }

    printMembers() {
        console.log("Members:")
        console.log(encodeURIComponent(this.name))
        this.members.forEach((m) => {
            console.log(encodeURIComponent(m.name))
        })
    }

    /**
     * Send all members one by one itself by script.
     */
    async updateMembers() {
        let chatPeerId = CHAT_PEER_ID;
        let relay = this.client.connection.nodePeerId.toB58String();
        let script = `
                (seq
                    (call "${relay}" ("identity" "") [] void1[])
                    (seq
                        (call "${chatPeerId}" ("${this.userListId}" "get_users") [] members)
                        (fold members m
                            (par
                                (seq
                                    (call "${relay}" ("identity" "") [] void[])
                                    (call "${this.client.selfPeerIdStr}" ("${this.chatId}" "join") [m] void3[])                            
                                )                        
                                (next m)
                            )    
                        )               
                    )
                )
                `

        let particle = await build(this.client.selfPeerId, script, new Map(), 600000)
        await this.client.sendParticle(particle)
    }

    /**
     * Rejoin with another name.
     * @param name
     */
    async changeName(name: string) {
        this.name = name;
        await this.join();
    }

    /**
     * Reconnects to other relay and publish new relay address.
     * @param multiaddr
     */
    async reconnect(multiaddr: string) {
        await this.client.connect(multiaddr);
        this.relay = this.client.connection.nodePeerId.toB58String();
        await this.join();
    }

    private deleteMember(clientId: string) {
        this.members = this.members.filter(m => m.clientId !== clientId)
    }

    private static notifyNameChanged(oldName: string, name: string) {
        sendEventMessage({msg: `Member '${decodeURIComponent(oldName)}' changed name to '${decodeURIComponent(name)}'.`, name: "", id: 0, replyTo: null})
    }

    private static notifyRelayChanged(relay: string) {
        sendEventMessage({msg: `Member '${relay}' changed its relay address.'.`, name: "", id: 0, replyTo: null})
    }

    private static notifyNewMessage(msg: ElmMessage) {
        sendEventMessage(msg)
    }

    private static notifyNewMember(name: string) {
        sendEventMessage({msg: `Member joined: ${decodeURIComponent(name)}.`, name: "", id: 0, replyTo: null})
    }

    private addMember(member: Member) {
        if (member.clientId !== this.client.selfPeerIdStr) {
            let oldMember = this.members.find((m) => m.clientId === member.clientId)
            if (!oldMember) {
                FluenceChat.notifyNewMember(member.name)
            } else {
                if (oldMember.name !== member.name) {
                    FluenceChat.notifyNameChanged(oldMember.name, member.name);
                }

                if (oldMember.relay !== member.relay) {
                    FluenceChat.notifyRelayChanged(member.relay)
                }
            }
            this.members = this.members.filter(m => m.clientId !== member.clientId)
            this.members.push(member)
        }
    }

    /**
     * Quit from chat.
     */
    async quit() {
        let user = this.client.selfPeerIdStr;
        let script = this.genScript(this.historyId, "delete", ["user", "signature"])

        let data = new Map()
        data.set("user", user)
        data.set("signature", user)

        let particle = await build(this.client.selfPeerId, script, data, 600000)
        await this.client.sendParticle(particle)

        console.log("You left chat.")
    }

    private getHistoryScript(): string {
        let chatPeerId = CHAT_PEER_ID;
        let relay = this.client.connection.nodePeerId.toB58String();

        return `
(seq
    (call "${relay}" ("identity" "") [] void1[])
    (seq
        (call "${chatPeerId}" ("${this.historyId}" "get_all") [] messages)                       
        (seq
            (call "${relay}" ("identity" "") [] void[])
            (call "${this.client.selfPeerIdStr}" ("${this.chatId}" "all_msgs") [messages] void3[])                            
        )                                                                           
    )
)
        `
    }

    /**
     * Print all history to a console.
     */
    async getHistory(): Promise<any> {
        let script = this.getHistoryScript();
        let particle = await build(this.client.selfPeerId, script, new Map(), 600000)
        await this.client.sendParticle(particle)
    }

    /**
     * Send message to chat. Notice all connected members.
     * @param msg
     * @param replyTo
     */
    async sendMessage(msg: string, replyTo: number) {
        let chatPeerId = CHAT_PEER_ID
        let relay = this.client.connection.nodePeerId.toB58String();
        let script = `
(seq
    (call "${relay}" ("identity" "") [] void1[])
    (seq
        (call "${chatPeerId}" ("${this.historyId}" "add") [author msg reply_to] id)
        (seq
            (call "${chatPeerId}" ("${this.userListId}" "get_users") [] members)
            (fold members m
                (par 
                    (seq 
                        (call m.$.["relay_id"] ("identity" "") [] void[])
                        (call m.$.["peer_id"] ("${this.chatId}" "add") [id author msg reply_to] void3[])                            
                    )                        
                    (next m)
                )                
            )
        )
    )
)
                `

        let data = new Map()
        data.set("author", this.client.selfPeerIdStr)
        data.set("msg", encodeURIComponent(msg))
        data.set("reply_to", replyTo)

        let particle = await build(this.client.selfPeerId, script, data, 600000)
        await this.client.sendParticle(particle)
    }

    printJoinScript() {
        console.log(this.genScript(this.userListId, "join", ["user", "relay", "sig", "name"]))
    }

    printGetHistoryScript() {
        console.log(this.getHistoryScript())
    }

    printSendMessageScript() {
        console.log(this.genScript(this.historyId, "add", ["author", "msg"]))
    }

    /**
     * Generate a script that will pass arguments to remote service and will send notifications to all chat members.
     * @param serviceId service to send
     * @param funcName function to call
     * @param args
     */
    private genScript(serviceId: string, funcName: string, args: string[]): string {
        let argsStr = args.join(" ")
        let chatPeerId = CHAT_PEER_ID
        let relay = this.client.connection.nodePeerId.toB58String();
        return `
(seq
    (call "${relay}" ("identity" "") [] void1[])
    (seq
        (call "${chatPeerId}" ("${serviceId}" "${funcName}") [${argsStr}] void2[])
        (seq
            (call "${chatPeerId}" ("${this.userListId}" "get_users") [] members)
            (fold members m
                (par 
                    (seq 
                        (call m.$.["relay_id"] ("identity" "") [] void[])
                        (call m.$.["peer_id"] ("${this.chatId}" "${funcName}") [${argsStr}] void3[])                            
                    )                        
                    (next m)
                )                
            )
        )
    )
)
                `
    }
}
