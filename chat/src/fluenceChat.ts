import {FluenceClient} from "fluence/dist/fluenceClient";
import {registerService} from "fluence/dist/globalState";
import {Service} from "fluence/dist/service";
import {build} from "fluence/dist/particle";
import {CHAT_PEER_ID} from "./index";

export const HISTORY_NAME = "history"
export const USER_LIST_NAME = "user-list"

export interface Member {
    clientId: string,
    relay: string,
    sig: string,
    name: string
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
            let m;
            if (Array.isArray(args[0])) {
                m = args[0]
            } else {
                m = args
            }
            let member = {
                clientId: m[0],
                relay: m[1],
                sig: m[2],
                name: m[3]
            }
            this.addMember(member);
            return {}
        })

        service.registerFunction("all_msgs", (args: any[]) => {
            args[0].forEach((v: any) => {
                let name;
                if (v[2] === this.client.selfPeerIdStr) {
                    name = "Me"
                } else {
                    name = this.members.find(m => m.clientId === v[2])?.name
                }
                if (name) {
                    console.log(`${decodeURIComponent(name)}: ${decodeURIComponent(v[1])}`)
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
            let m = this.members.find(m => m.clientId === args[0])
            if (m) {
                console.log(`${decodeURIComponent(m.name)}: ${decodeURIComponent(args[1])}`)
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

    private static printNameChanged(oldName: string, name: string) {
        console.log(`Member '${decodeURIComponent(oldName)}' changed name to '${decodeURIComponent(name)}'.`)
    }

    private static printRelayChanged(relay: string) {
        console.log(`Member '${relay}' changed its relay address.'.`)
    }

    private addMember(member: Member) {
        if (member.clientId !== this.client.selfPeerIdStr) {
            let oldMember = this.members.find((m) => m.clientId === member.clientId)
            if (!oldMember) {
                console.log(`Member joined: ${decodeURIComponent(member.name)}.`)
            } else {
                if (oldMember.name !== member.name) {
                    FluenceChat.printNameChanged(oldMember.name, member.name);
                }

                if (oldMember.relay !== member.relay) {
                    FluenceChat.printRelayChanged(member.relay)
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
     */
    async sendMessage(msg: string) {
        let script = this.genScript(this.historyId, "add", ["author", "msg"])
        let data = new Map()
        data.set("author", this.client.selfPeerIdStr)
        data.set("msg", encodeURIComponent(msg))

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
                        (call m.$.[1] ("identity" "") [] void[])
                        (call m.$.[0] ("${this.chatId}" "${funcName}") [${argsStr}] void3[])                            
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
