import "regenerator-runtime";
import Hash from 'ipfs-only-hash';
import bs58 from 'bs58';

import Fluence from 'fluence';
import {genUUID} from "fluence/dist/function_call";

import {downloadBlob, getPreview, ipfsAdd, ipfsGet} from "./fileUtils";
import {peerIdToSeed, seedToPeerId} from "fluence/dist/seed";
import * as PeerId from "peer-id";

let Address4 = require('ip-address').Address4;

let relays = [
    {peer: {id: "12D3KooWEXNUbCXooUwHrHBbrmjsrpHXoEphPwbjQXEGyzbqKnE9", seed: null}, dns: "relay01.fluence.dev", pport: 19001},
    {peer: {id: "12D3KooWHk9BjDQBUqnavciRPhAYFvqKBe4ZiPPvde7vDaqgn5er", seed: null}, dns: "relay01.fluence.dev", pport: 19002},
    {peer: {id: "12D3KooWBUJifCTgaxAUrcM9JysqCcS4CS8tiYH5hExbdWCAoNwb", seed: null}, dns: "relay01.fluence.dev", pport: 19003},
    {peer: {id: "12D3KooWJbJFaZ3k5sNd8DjQgg3aERoKtBAnirEvPV8yp76kEXHB", seed: null}, dns: "relay01.fluence.dev", pport: 19004},
    {peer: {id: "12D3KooWCKCeqLPSgMnDjyFsJuWqREDtKNHx1JEBiwaMXhCLNTRb", seed: null}, dns: "relay01.fluence.dev", pport: 19005},
    {peer: {id: "12D3KooWMhVpgfQxBLkQkJed8VFNvgN4iE6MD7xCybb1ZYWW2Gtz", seed: null}, dns: "relay01.fluence.dev", pport: 19990},
    {peer: {id: "12D3KooWPnLxnY71JDxvB3zbjKu9k1BCYNthGZw6iGrLYsR1RnWM", seed: null}, dns: "relay01.fluence.dev", pport: 19100},
];

function to_multiaddr(relay) {
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

function subsribeToApper(app, conn, peerIdStr) {
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

// event with an error message
let peerErrorEvent = (app, errorMsg) => {
    app.ports.connReceiver.send({event: "error", relay: null, peer: null, errorMsg});
}

// new peer is generated
let peerEvent = (app, name, peer) => {
    let peerToSend = {seed: null, ...peer};
    app.ports.connReceiver.send({event: name, relay: null, errorMsg: null, peer: peerToSend});
}

// new relay connection established
let relayEvent = (app, name, relay) => {
    let relayToSend = null;
    if (relay) {
        relayToSend = {dns: null, host: null, ...relay};
    }
    let ev = {event: name, peer: null, errorMsg: null, relay: relayToSend};
    app.ports.connReceiver.send(ev);
};

// call if we found out about any peers or relays in Fluence network
let peerAppearedEvent = (app, peer, peerType, updateDate) => {
    let peerAppeared = { peer: {id: peer}, peerType, updateDate};
    app.ports.networkMapReceiver.send({event: "peer_appeared", peerAppeared});
};

/**
 * Handle file commands, sending events
 */
let emptyFileEvent = {log: null, preview: null};
let sendToFileReceiver = (app, ev) => {
    app.ports.fileReceiver.send({...emptyFileEvent, ...ev});
};

let fileAdvertised = (app, hash, preview) =>
    sendToFileReceiver(app,{event: "advertised", hash, preview});
let fileUploading = (app, hash) =>
    sendToFileReceiver(app, {event: "uploading", hash});
let fileUploaded = (app, hash) =>
    sendToFileReceiver(app, {event: "uploaded", hash});
let fileDownloading = (app, hash) =>
    sendToFileReceiver(app, {event: "downloading", hash});
let fileAsked = (app, hash) =>
    sendToFileReceiver(app, {event: "asked", hash});
let fileRequested = (app, hash) =>
    sendToFileReceiver(app, {event: "requested", hash});
let fileLoaded = (app, hash, preview) =>
    sendToFileReceiver(app, {event: "loaded", hash, preview});
let hashCopied = (app, hash) =>
    sendToFileReceiver(app, {event: "copied", hash});
let fileLog = (app, hash, log) =>
    sendToFileReceiver(app,{event: "log", hash, log});

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

    let currentPeerId;
    let conn;

    relays.map(d => relayEvent(app, "relay_discovered", d));

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
                    relayEvent(app, "relay_connecting");
                    // if the connection already established, connect to another node and save previous services and subscriptions
                    conn = await conn.connect(to_multiaddr(relay), relay.peer.id);
                    relayEvent(app, "relay_connected", relay);
                }

                break;

            case "generate_peer":
                console.log("generate peer")
                let peerId = await Fluence.generatePeerId();
                currentPeerId = peerId;
                let peerIdStr = peerId.toB58String();
                peerEvent(app, "set_peer", {id: peerIdStr});
                break;

            case "connect_to":
                let errorMsg = "";
                try {
                    if (connectTo) {
                        let isIp = false;
                        if (!connectTo.host) {
                            errorMsg = errorMsg + "Host must be present\n"
                        } else {
                            let addr = new Address4(connectTo.host);
                            if (addr.isValid()) {
                                isIp = true
                            }
                        }

                        let port;
                        if (!connectTo.pport) {
                            errorMsg = errorMsg + "Port must be present\n"
                        } else {
                            try {
                                port = parseInt(connectTo.pport)
                            } catch (e) {
                                errorMsg = errorMsg + "Port must be a number\n"
                            }
                        }

                        if (!connectTo.peerId) {
                            errorMsg = errorMsg + "Relay peerId must be present\n"
                        } else {
                            await PeerId.createFromB58String(connectTo.peerId);
                        }

                        if (errorMsg) {
                            peerErrorEvent(app, errorMsg);
                            break;
                        }

                        let peerId;
                        let seed;
                        if (connectTo.seed) {
                            peerId = await seedToPeerId(connectTo.seed);
                            seed = connectTo.seed;
                        } else {
                            peerId = await Fluence.generatePeerId();
                            seed = peerIdToSeed(peerId);
                            console.log("SEED GENERATED: " + seed)
                        }

                        currentPeerId = peerId;
                        peerEvent(app, "set_peer", {id: peerId.toB58String(), seed});
                        relayEvent(app, "relay_connecting");
                        let host = null;
                        let dns = null;
                        if (isIp) {
                            host = connectTo.host
                        } else {
                            dns = connectTo.host
                        }
                        let relay = {
                            host: host,
                            pport: port,
                            peer: { id: connectTo.peerId, seed: null },
                            dns: dns
                        }
                        conn = await Fluence.connect(to_multiaddr(relay), peerId);

                        relayEvent(app,"relay_connected", relay);
                    }
                } catch (e) {
                    console.log(e);
                    peerErrorEvent(app,errorMsg + e.message);
                }

                break;

            case "random_connect":
                console.log("random connect")
                // connect to a random node
                let randomNodeNum = Math.floor(Math.random() * relays.length);
                let randomRelay = relays[randomNodeNum];

                relayEvent(app,"relay_connecting");

                // TODO: disconnect old connection
                conn = await Fluence.connect(to_multiaddr(randomRelay), currentPeerId);

                relayEvent(app,"relay_connected", randomRelay);
                subsribeToApper(app, conn, currentPeerId.toB58String())
                break;

            default:
                console.error("Received unknown connRequest from the Elm app", command);
        }
    });

    let multiaddrService = "IPFS.multiaddr";

    let knownFiles = {};

    // callback to add a local file in Fluence network
    app.ports.selectFile.subscribe(async () => {
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
                        console.log("going to upload");
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
                console.log("This file is already advertised.");
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

    // call to show or hide network map
    let showHideEvent = () => {
        app.ports.networkMapReceiver.send({event: "show-hide", peerAppeared: null});
    };

    // call it to open the field with appeared peers and clients
    window.networkMap = () => {
        showHideEvent()
    }
}