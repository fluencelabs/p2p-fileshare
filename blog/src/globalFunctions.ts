import {FluenceBlog, HISTORY_NAME, USER_LIST_NAME} from "./fluenceBlog";
import {FluenceClient} from "fluence/dist/fluenceClient";
import {peerIdToSeed, seedToPeerId} from "fluence/dist/seed";
import {SQLITE_BS64} from "../../artifacts/sqliteBs64";
import {HISTORY_BS64} from "../../artifacts/historyBs64";
import {USER_LIST_BS64} from "../../artifacts/userListBs64";
import {BLOG_PEER_ID, COMMENTS_HISTORY_BLUEPRINT, relays, USER_LIST_BLUEPRINT} from "./main";
import Fluence from "fluence";

export let currentBlog: FluenceBlog | undefined = undefined;

function chatIdToHistoryId(chatId: string) {
    return chatId + "_history"
}

function chatIdToUserListId(chatId: string) {
    return chatId + "_userlist"
}

function getRandomRelayAddr(): string {
    let relay = Math.floor(Math.random() * relays.length)
    return relays[relay].multiaddr
}

// Create a new chat. Chat Id will be printed in a console.
// New peer id will be generated with empty 'seed'. Random relay address will be used with empty 'relayAddress'
export async function createBlog(name: string, seed?: string, relayAddress?: string): Promise<FluenceBlog> {
    checkCurrentBlog();
    let clCreation = await connect(relays[1].multiaddr, false);
    let userListIdPr = clCreation.createService(USER_LIST_BLUEPRINT, undefined, 20000);
    let historyIdPr = clCreation.createService(COMMENTS_HISTORY_BLUEPRINT, undefined, 20000);

    let userListId = await userListIdPr;
    let historyId = await historyIdPr;

    let blogId = Math.random().toString(36).substring(7);
    await clCreation.addProvider(Buffer.from(chatIdToHistoryId(blogId), 'utf8'), relays[1].peerId, historyId);
    await clCreation.addProvider(Buffer.from(chatIdToUserListId(blogId), 'utf8'), relays[1].peerId, userListId);

    console.log("CHAT ID: " + blogId);

    if (!relayAddress) {
        relayAddress = getRandomRelayAddr()
        console.log(`Connect to random node: ${relayAddress}`)
    }

    let cl = await connect(relayAddress, true, seed);

    let chat =  new FluenceBlog(cl, blogId, historyId, userListId, BLOG_PEER_ID, name, cl.connection.nodePeerId.toB58String());
    await chat.join();

    currentBlog = chat;

    return chat;
}

// Get an info about chat providers from Kademlia network.
export async function getInfo(chatId: string): Promise<{ historyId: string; userListId: string }> {
    let clInfo = await connect(relays[1].multiaddr, false);

    let historyId = (await clInfo.getProviders(Buffer.from(chatIdToHistoryId(chatId), 'utf8')))[0][0].service_id;
    let userListId = (await clInfo.getProviders(Buffer.from(chatIdToUserListId(chatId), 'utf8')))[0][0].service_id;

    return { historyId, userListId }
}

// Throws an error if the chat client been already created.
function checkCurrentBlog() {
    if (currentBlog) {
        throw new Error("Chat is already created. Use 'chat' variable to use it. Or refresh page to create a new one.")
    }
}

// Join to existed chat. New peer id will be generated with empty 'seed'. Random relay address will be used with empty 'relayAddress'
export async function joinBlog(name: string, blogId: string, seed?: string, relayAddress?: string): Promise<FluenceBlog> {
    checkCurrentBlog();
    let info = await getInfo(blogId)

    if (!relayAddress) {
        relayAddress = getRandomRelayAddr()
        console.log(`Connect to random node: ${relayAddress}`)
    }

    let cl = await connect(relayAddress, true, seed);

    let blog = new FluenceBlog(cl, blogId, info.historyId, info.userListId, BLOG_PEER_ID, name, cl.connection.nodePeerId.toB58String());
    console.log("You joined to chat.")
    await blog.join();
    await blog.getHistory();

    currentBlog = blog;

    return blog;
}

// Connect to one of the node. Generate seed if it is undefined.
export async function connect(relayAddress: string, printPid: boolean, seed?: string): Promise<FluenceClient> {
    let pid;
    if (seed) {
        pid = await seedToPeerId(seed);
    } else {
        pid = await Fluence.generatePeerId();
    }

    if (printPid) {
        console.log("SEED = " + peerIdToSeed(pid))
        console.log("PID = " + pid.toB58String())
    }

    return await Fluence.connect(relayAddress, pid);
}

// Publishes a blueprint for chat application and shows its id
export async function publishBlueprint() {
    let pid = await Fluence.generatePeerId();
    let cl = await Fluence.connect(relays[1].multiaddr, pid);

    await cl.addModule("sqlite3", SQLITE_BS64, undefined, 20000);
    await cl.addModule(HISTORY_NAME, HISTORY_BS64, undefined, 20000);
    await cl.addModule(USER_LIST_NAME, USER_LIST_BS64, undefined, 20000);

    let blueprintIdPostsHistory = await cl.addBlueprint("post_history", ["sqlite3", HISTORY_NAME])
    let blueprintIdCommentsHistory = await cl.addBlueprint("comment_history", ["sqlite3", HISTORY_NAME])
    let blueprintIdUserList = await cl.addBlueprint("user_list", ["sqlite3", USER_LIST_NAME])
    console.log(`BLUEPRINT POSTS HISTORY ID: ${blueprintIdPostsHistory}`)
    console.log(`BLUEPRINT COMMENTS HISTORY ID: ${blueprintIdCommentsHistory}`)
    console.log(`BLUEPRINT USER LIST ID: ${blueprintIdUserList}`)
}