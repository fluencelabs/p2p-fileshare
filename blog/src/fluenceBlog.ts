import {FluenceClient} from "fluence/dist/fluenceClient";
import {registerService} from "fluence/dist/globalState";
import {Service} from "fluence/dist/service";
import {build} from "fluence/dist/particle";
import {BLOG_PEER_ID} from "./main";
import {sendEventComment, sendEventPost} from "./blog";

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

export class FluenceBlog {
    client: FluenceClient
    historyId: string
    userListId: string
    blogId: string
    name: string
    relay: string
    blogPeerId: string

    constructor(client: FluenceClient, chatId: string, commentsHistoryId: string, userListId: string, blogPeerId: string, name: string, relay: string) {
        this.client = client;
        this.name = name;
        this.historyId = commentsHistoryId;
        this.userListId = userListId;
        this.relay = relay;
        this.blogPeerId = blogPeerId;
        this.blogId = chatId;

        // register service with function that will handle incoming messages from a chat
        let service = new Service(this.blogId)
        service.registerFunction("all_msgs", (args: any[]) => {
            console.log("ALL MSGS")
            console.log(args)
            let messages: Message[] = args[0]
            let members: Member[] = args[1]
            let names = new Map<string, string>()
            members.forEach((m) => {
                names.set(m.clientId, m.name)
            })

            messages.forEach((msg) => {

                if (msg.reply_to === 0) {
                    FluenceBlog.notifyNewPost(msg.id, msg.body)
                } else {
                    FluenceBlog.notifyNewComment(names.get(msg.author), msg.body, msg.reply_to)
                }

            })

            return {}
        })

        service.registerFunction("add_comment", (args: any[]) => {
            FluenceBlog.notifyNewComment(args[0], args[1], args[2])

            return {}
        })

        service.registerFunction("add_post", (args: any[]) => {
            FluenceBlog.notifyNewPost(args[0], args[1])

            return {}
        })

        registerService(service)
    }

    /**
     * Call 'join' service and send notifications to all members.
     */
    async join() {
        let chatPeerId = BLOG_PEER_ID
        let relay = this.client.connection.nodePeerId.toB58String();
        let script = `
(seq
    (call "${relay}" ("identity" "") [])    
    (call "${chatPeerId}" ("${this.userListId}" "join") [user])            
)
                `

        let data = new Map()
        let user = {
            peer_id: this.client.selfPeerIdStr,
            relay_id: this.client.connection.nodePeerId.toB58String(),
            signature: this.client.selfPeerIdStr,
            name: this.name
        }
        data.set("user", user)

        let particle = await build(this.client.selfPeerId, script, data, 600000)
        await this.client.sendParticle(particle)
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

    private static notifyNewPost(id: number, msg: string) {
        sendEventPost(id, msg)
    }

    private static notifyNewComment(name: string, msg: string, id: number) {
        sendEventComment(msg, name, id)
    }

    private getHistoryScript(): string {
        let chatPeerId = BLOG_PEER_ID;
        let relay = this.client.connection.nodePeerId.toB58String();

        return `
(seq
    (call "${relay}" ("identity" "") [])
    (seq
        (call "${chatPeerId}" ("${this.historyId}" "get_all") [] messages)  
        (seq
            (call "${chatPeerId}" ("${this.userListId}" "get_users") [] members)                     
            (seq
                (call "${relay}" ("identity" "") [] void[])
                (call "${this.client.selfPeerIdStr}" ("${this.blogId}" "all_msgs") [messages.$.["messages"] members.$.["users"]])                            
            )
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
    async sendComment(msg: string, replyTo: number) {
        let chatPeerId = BLOG_PEER_ID
        let relay = this.client.connection.nodePeerId.toB58String();
        let script =
`
(seq
    (call "${relay}" ("identity" "") [])
    (seq
        (call "${chatPeerId}" ("${this.historyId}" "add") [author msg reply_to] id)
        (seq
            (call "${chatPeerId}" ("${this.userListId}" "get_user") [author] user)
            (seq
                (call "${chatPeerId}" ("${this.userListId}" "get_users") [] members)
                (fold members.$.["users"] m
                    (par 
                        (seq 
                            (call m.$.["relay_id"] ("identity" "") [])
                            (call m.$.["peer_id"] ("${this.blogId}" "add_comment") [user.$.[0]["name"] msg reply_to])                            
                        )                        
                        (next m)
                    )                
                )
            )
        )
    )
)
`
        let data = new Map()
        data.set("msg", msg)
        data.set("author", this.client.selfPeerIdStr)
        data.set("reply_to", replyTo)

        let particle = await build(this.client.selfPeerId, script, data, 600000)
        await this.client.sendParticle(particle)
    }

    async sendPost(msg: string) {
        let chatPeerId = BLOG_PEER_ID
        let relay = this.client.connection.nodePeerId.toB58String();
        let script =
            `
(seq
    (call "${relay}" ("identity" "") [])
    (seq
        (call "${chatPeerId}" ("${this.historyId}" "add") [author msg zero] id)       
        (seq
            (call "${chatPeerId}" ("${this.userListId}" "get_users") [] members)
            (fold members.$.["users"] m
                (par 
                    (seq 
                        (call m.$.["relay_id"] ("identity" "") [])
                        (call m.$.["peer_id"] ("${this.blogId}" "add_post") [id.$.["msg_id"] msg])     
                    )                        
                    (next m)
                )                
            )
        )       
    )
)
`
        let data = new Map()
        data.set("msg", msg)
        data.set("author", this.client.selfPeerIdStr)
        data.set("zero", 0)

        let particle = await build(this.client.selfPeerId, script, data, 600000)
        await this.client.sendParticle(particle)
    }
}
