import "regenerator-runtime";
import Hash from 'ipfs-only-hash';
import bs58 from 'bs58';

import Fluence from 'fluence';
import {genUUID} from "fluence/dist/function_call";
import {establishConnection, initAdmin} from "./admin"

import {downloadBlob, getPreview, ipfsAdd, ipfsGet} from "./fileUtils";

let relays = [
    {peer: {id: "12D3KooWEXNUbCXooUwHrHBbrmjsrpHXoEphPwbjQXEGyzbqKnE9", privateKey: null}, dns: "relay01.fluence.dev", pport: 19001},
    {peer: {id: "12D3KooWHk9BjDQBUqnavciRPhAYFvqKBe4ZiPPvde7vDaqgn5er", privateKey: null}, dns: "relay01.fluence.dev", pport: 19002},
    {peer: {id: "12D3KooWBUJifCTgaxAUrcM9JysqCcS4CS8tiYH5hExbdWCAoNwb", privateKey: null}, dns: "relay01.fluence.dev", pport: 19003},
    {peer: {id: "12D3KooWJbJFaZ3k5sNd8DjQgg3aERoKtBAnirEvPV8yp76kEXHB", privateKey: null}, dns: "relay01.fluence.dev", pport: 19004},
    {peer: {id: "12D3KooWCKCeqLPSgMnDjyFsJuWqREDtKNHx1JEBiwaMXhCLNTRb", privateKey: null}, dns: "relay01.fluence.dev", pport: 19005},
    {peer: {id: "12D3KooWMhVpgfQxBLkQkJed8VFNvgN4iE6MD7xCybb1ZYWW2Gtz", privateKey: null}, dns: "relay01.fluence.dev", pport: 19990},
    {peer: {id: "12D3KooWPnLxnY71JDxvB3zbjKu9k1BCYNthGZw6iGrLYsR1RnWM", privateKey: null}, dns: "relay01.fluence.dev", pport: 19100},
];

export function getRelays() {
    return relays;
}

// current state is here
// TODO: maybe move it to a class?
let currentPeerId;
let conn;
let knownFiles = {};

export function addRelay(app, relay) {
    // TODO: if the same peerId with different ip addresses?
    if (!relays.find(r => r.peer.id === relay.peer.id)) {
        relayEvent(app, "relay_discovered", relay)
        relays.push(relay)
    }
}

export function getCurrentPeerId() {
    return currentPeerId
}

export function setCurrentPeerId(peerId) {
    currentPeerId = peerId;
}

export function setConnection(app, connection) {
    // if we create new connection - reset all old file entries
    resetEntries(app);
    knownFiles = {};
    conn = connection;

    subsribeToAppear(app, conn, getCurrentPeerId())
}

export function getConnection() {
    return conn
}

export function to_multiaddr(relay) {
    let host;
    let protocol;
    if (relay.host) {
        host = "/ip4/" + relay.host;
        protocol = "ws"
    } else {
        host = "/dns4/" + relay.dns;
        protocol = "wss"
    }
    return `${host}/tcp/${relay.pport}/${protocol}/p2p/${relay.peer.id}`;
}

function subsribeToAppear(app, conn, peerIdStr) {
    // subscribe for all outgoing calls to watch for all Fluence network members
    conn.subscribe((args, target, replyTo) => {
        let date = new Date().toISOString();
        if (!!replyTo) {
            for (const protocol of replyTo.protocols) {
                if (protocol.protocol !== 'signature' && protocol.value !== peerIdStr) {
                    peerAppearedEvent(app, protocol.value, protocol.protocol, date)
                }
            }
        }
    });
}

// TODO move all ports to different files
// event with an error message
export function peerErrorEvent(app, errorMsg) {
    app.ports.connReceiver.send({event: "error", relay: null, peer: null, errorMsg});
}

// new peer is generated
export function peerEvent(app, name, peer) {
    let peerToSend = {privateKey: null, ...peer};
    app.ports.connReceiver.send({event: name, relay: null, errorMsg: null, peer: peerToSend});
}

export function convertRelayForELM(relay) {
    let host;
    if (relay.host) {
        host = relay.host;
    } else {
        host = relay.dns;
    }
    return {host: host, peer: relay.peer, pport: relay.pport};
}

// new relay connection established
export function relayEvent(app, name, relay) {
    let relayToSend = null;
    if (relay) {
        relayToSend = convertRelayForELM(relay)
    }
    let ev = {event: name, peer: null, errorMsg: null, relay: relayToSend};
    app.ports.connReceiver.send(ev);
}

// call if we found out about any peers or relays in Fluence network
export function peerAppearedEvent(app, peer, peerType, updateDate) {
    let peerAppeared = { peer: {id: peer}, peerType, updateDate};
    app.ports.networkMapReceiver.send({event: "peer_appeared", certs: null, id: null, peerAppeared});
}

/**
 * Handle file commands, sending events
 */
let emptyFileEvent = {hash: null, log: null, preview: null};
export function sendToFileReceiver(app, ev) {
    app.ports.fileReceiver.send({...emptyFileEvent, ...ev});
}

export function fileAdvertised(app, hash, preview) {
    sendToFileReceiver(app,{event: "advertised", hash, preview});
}
export function fileUploading(app, hash) {
    sendToFileReceiver(app, {event: "uploading", hash});
}
export function fileUploaded(app, hash) {
    sendToFileReceiver(app, {event: "uploaded", hash});
}
export function fileDownloading(app, hash) {
    sendToFileReceiver(app, {event: "downloading", hash});
}
export function fileAsked(app, hash) {
    sendToFileReceiver(app, {event: "asked", hash});
}
export function fileRequested(app, hash) {
    sendToFileReceiver(app, {event: "requested", hash});
}
export function fileLoaded(app, hash, preview) {
    sendToFileReceiver(app, {event: "loaded", hash, preview});
}
export function hashCopied(app, hash) {
    sendToFileReceiver(app, {event: "copied", hash});
}
export function fileLog(app, hash, log) {
    sendToFileReceiver(app,{event: "log", hash, log});
}
export function resetEntries(app) {
    sendToFileReceiver(app,{event: "reset_entries"});
}

function validateHash(hash) {
    if (typeof hash === "string" && hash.length === 46 && hash.substring(0, 2) === "Qm") {
        try {
            bs58.decode(hash);
            return true;
        } catch (e) {
            console.error(`Cannot decode hash '${hash}': ${e}`)
        }
    }

    return false;
}

export default async function ports(app) {

    await initAdmin(app);

    // add all relays from list as appeared
    let date = new Date().toISOString();
    for (const relay of relays) {
        peerAppearedEvent(app, relay.peer.id, "peer", date)
    }

    /**
     * Handle connection commands
     */
    app.ports.connRequest.subscribe(async ({command, id, connectTo}) => {
        switch (command) {
            case "set_relay":
                let relay = relays.find(r => r.peer.id === id);
                if (relay) {
                    if (!getCurrentPeerId()) {
                        break;
                    }

                    relayEvent(app, "relay_connecting");
                    // if the connection already established, connect to another node and save previous services and subscriptions
                    if (conn) {
                        conn.connect(to_multiaddr(relay));
                    } else {
                        setConnection(app, await Fluence.connect(to_multiaddr(relay), getCurrentPeerId()));
                    }

                    relayEvent(app, "relay_connected", relay);
                }

                break;

            case "generate_peer":
                let peerId = await Fluence.generatePeerId();
                currentPeerId = peerId;
                let peerIdStr = peerId.toB58String();
                peerEvent(app, "set_peer", {id: peerIdStr});
                break;

            case "connect_to":
                await establishConnection(app, connectTo);

                break;

            default:
                console.error("Received unknown connRequest from the Elm app", command);
        }
    });

    let multiaddrService = "IPFS.multiaddr";

    // callback to add a local file in Fluence network
    app.ports.selectFile.subscribe(async () => {

        if (!getConnection()) {
            console.error("Establish connection before adding files.")
            return;
        }

        let input = document.createElement('input');
        input.type = 'file';

        input.onchange = async e => {
            let file = e.target.files[0];
            let arrayBuffer = await file.arrayBuffer();
            let array = new Uint8Array(arrayBuffer);

            let hash = await Hash.of(array);

            if (!knownFiles[hash]) {

                fileRequested(app, hash);

                let previewStr = getPreview(array);

                knownFiles[hash] = {bytes: array, preview: previewStr};

                let serviceName = "IPFS.get_" + hash;

                fileLog(app, hash, "Going to advertise");
                fileLoaded(app, hash, previewStr);
                await conn.registerService(serviceName, async fc => {
                    fileLog(app, hash, "File asked");

                    let replyWithMultiaddr = async (multiaddr) =>
                        await conn.sendCall(fc.reply_to, {msg_id: fc.arguments.msg_id, multiaddr});

                    // check cache
                    if (knownFiles[hash].multiaddr) {
                        await replyWithMultiaddr(knownFiles[hash].multiaddr)
                    } else {

                        // call multiaddr
                        let msgId = genUUID();

                        let multiaddrResult = await conn.sendServiceCallWaitResponse(multiaddrService, {msg_id: msgId}, (args) => args.msg_id && args.msg_id === msgId);
                        let multiaddr = multiaddrResult.multiaddr;
                        // upload a file
                        fileUploading(app, hash);
                        await ipfsAdd(multiaddr, knownFiles[hash].bytes);
                        fileUploaded(app, hash);
                        fileLog(app, hash, "File uploaded to " + multiaddr);
                        knownFiles[hash].multiaddr = multiaddr;
                        // send back multiaddr
                        await replyWithMultiaddr(multiaddr);
                    }

                    fileAsked(app, hash);

                });
                fileLog(app, hash, "File advertised on Fluence network");

                fileAdvertised(app, hash, previewStr);

            } else {
                fileLog(app, hash, "Trying to advertise this file, but the file is already advertised.");
            }
        };

        input.click();
    });

    app.ports.fileRequest.subscribe(async ({command, hash}) => {
        // TODO Queue, and handle commands once (re)connected
        if (!conn) console.error("Cannot handle fileRequest when not connected");
        else
            switch (command) {
                case "download":
                    if (!!knownFiles[hash] && (knownFiles[hash].bytes && knownFiles[hash].bytes.length > 0)) {
                        downloadBlob(knownFiles[hash].bytes, hash, 'application/octet-stream');
                    } else console.error("Cannot download as file is unknown for hash: " + hash);
                    break;
                case "copy":
                    const el = document.createElement('textarea');
                    el.value = hash;
                    document.body.appendChild(el);
                    el.select();
                    document.execCommand('copy');
                    document.body.removeChild(el);
                    hashCopied(app, hash);
                    break;
                default:
                    console.error("Received unknown fileRequest from the Elm app", command);

            }
    });

    // callback to add a file from Fluence network by hash
    app.ports.addFileByHash.subscribe(async (hash) => {

        if (!validateHash(hash)) {
            console.error(`Hash '${hash}' is not valid.`);
            fileLog(app, hash, `Hash is not valid.`);
            return;
        }

        fileRequested(app, hash);

        let file = knownFiles[hash];
        if (!!file && file.bytes && file.bytes.length > 0) {
            fileLog(app, hash, "This file is already known");
        } else {
            let msgId = genUUID();
            let serviceName = "IPFS.get_" + hash;

            fileLog(app, hash, "Trying to discover " + serviceName + ", msg_id=" + msgId);
            let multiaddrResult = await conn.sendServiceCallWaitResponse(serviceName, {msg_id: msgId}, (args) => args.msg_id && args.msg_id === msgId);
            let multiaddr = multiaddrResult.multiaddr;

            fileLog(app, hash, "Got multiaddr: " + multiaddr + ", going to download the file");

            fileDownloading(app, hash);
            let data = await ipfsGet(multiaddr, hash);
            fileLog(app, hash, "File downloaded from " + multiaddr);

            let preview = getPreview(data);

            fileLoaded(app, hash, preview);
            knownFiles[hash] = {
                bytes: data,
                multiaddr,
                preview
            };
        }

    });
}