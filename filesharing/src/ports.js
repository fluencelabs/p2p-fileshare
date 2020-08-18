/*
 * Copyright 2020 Fluence Labs Limited
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import "regenerator-runtime";
import Hash from 'ipfs-only-hash';
import bs58 from 'bs58';

import Fluence from 'fluence';

import {downloadBlob, getPreview, ipfsAdd, ipfsGet} from "./fileUtils";
import {
    fileAdvertised,
    fileAsked,
    fileDownloading,
    fileLoaded,
    fileLog, fileRequested,
    fileUploaded,
    fileUploading, hashCopied, resetEntries
} from "./fileReceiver";
import {peerEvent, relayEvent} from "./connectionReceiver";
import * as PeerId from "peer-id";
import {peerErrorEvent} from "../../admin/src/connectionReceiver";
import {peerIdToSeed, seedToPeerId} from "fluence/dist/seed";
import {setRelayPeerId} from "../../admin/src/admin";

let relays = [
    {peer: {id: "12D3KooWEXNUbCXooUwHrHBbrmjsrpHXoEphPwbjQXEGyzbqKnE9", privateKey: null}, dns: "relay02.fluence.dev", pport: 19001},
    {peer: {id: "12D3KooWHk9BjDQBUqnavciRPhAYFvqKBe4ZiPPvde7vDaqgn5er", privateKey: null}, dns: "relay02.fluence.dev", pport: 19002},
    {peer: {id: "12D3KooWBUJifCTgaxAUrcM9JysqCcS4CS8tiYH5hExbdWCAoNwb", privateKey: null}, dns: "relay02.fluence.dev", pport: 19003},
    {peer: {id: "12D3KooWJbJFaZ3k5sNd8DjQgg3aERoKtBAnirEvPV8yp76kEXHB", privateKey: null}, dns: "relay02.fluence.dev", pport: 19004},
    {peer: {id: "12D3KooWCKCeqLPSgMnDjyFsJuWqREDtKNHx1JEBiwaMXhCLNTRb", privateKey: null}, dns: "relay02.fluence.dev", pport: 19005},
    {peer: {id: "12D3KooWMhVpgfQxBLkQkJed8VFNvgN4iE6MD7xCybb1ZYWW2Gtz", privateKey: null}, dns: "relay02.fluence.dev", pport: 19990},
    {peer: {id: "12D3KooWPnLxnY71JDxvB3zbjKu9k1BCYNthGZw6iGrLYsR1RnWM", privateKey: null}, dns: "relay02.fluence.dev", pport: 19100},
];

export function getRelays() {
    return relays;
}

// current state is here
// TODO: maybe move it to a class?
let currentPeerId;
let conn;
let knownFiles = {};
let app;

export function addRelay(app, relay) {
    // TODO: if the same peerId with different ip addresses?
    if (!relays.find(r => r.peer.id === relay.peer.id)) {
        relayEvent("relay_discovered", relay)
        relays.push(relay)
    }
}

export function getApp() {
    return app
}

export function setApp(newApp) {
    app = newApp
}

export function getCurrentPeerId() {
    return currentPeerId
}

export function setCurrentPeerId(peerId) {
    currentPeerId = peerId;
}

export function setConnection(app, connection) {
    // if we create new connection - reset all old file entries
    resetEntries();
    knownFiles = {};
    conn = connection;
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

    setApp(app)

    // add all relays from list as appeared
    let date = new Date().toISOString();

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

                    relayEvent("relay_connecting");
                    // if the connection already established, connect to another node and save previous services and subscriptions
                    if (conn) {
                        conn.connect(to_multiaddr(relay));
                    } else {
                        setConnection(app, await Fluence.connect(to_multiaddr(relay), getCurrentPeerId()));
                    }

                    relayEvent("relay_connected", relay);
                }

                break;

            case "generate_peer":
                let peerId = await Fluence.generatePeerId();
                currentPeerId = peerId;
                let peerIdStr = peerId.toB58String();
                peerEvent( "set_peer", {id: peerIdStr});
                break;

            case "connect_to":
                await establishConnection(app, connectTo);

                break;

            default:
                console.error("Received unknown connRequest from the Elm app", command);
        }
    });

    // TODO serviceId could be changed, get a new one on start with `getActiveInterfaces`
    let multiaddrServiceId = "c0365d76-b86c-4652-9de8-58d32b43aab8";
    let multiaddrModuleId = "ipfs_node.wasm";
    let multiaddrFname = "get_address";

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

                fileRequested(hash);

                let previewStr = getPreview(array);

                knownFiles[hash] = {bytes: array, preview: previewStr};

                let providerName = "IPFS.get_" + hash;

                fileLog(hash, "Going to advertise");
                fileLoaded(hash, previewStr);
                await conn.provideName(providerName, async fc => {
                    fileLog(hash, "File asked");

                    let replyWithMultiaddr = async (multiaddr) =>
                        await conn.sendCall({target: fc.reply_to, args: {multiaddr}});

                    // check cache
                    if (knownFiles[hash].multiaddr) {
                        await replyWithMultiaddr(knownFiles[hash].multiaddr)
                    } else {

                        // call multiaddr
                        let multiaddrResult = await conn.callService("12D3KooWPnLxnY71JDxvB3zbjKu9k1BCYNthGZw6iGrLYsR1RnWM", multiaddrServiceId, multiaddrModuleId, [], multiaddrFname);

                        let multiaddr = multiaddrResult.result;
                        // upload a file
                        fileUploading(hash);
                        await ipfsAdd(multiaddr, knownFiles[hash].bytes);
                        fileUploaded(hash);
                        fileLog(hash, "File uploaded to " + multiaddr);
                        knownFiles[hash].multiaddr = multiaddr;
                        // send back multiaddr
                        await replyWithMultiaddr(multiaddr);
                    }

                    fileAsked(hash);

                });
                fileLog(hash, "File advertised on Fluence network");

                fileAdvertised(hash, previewStr);

            } else {
                fileLog(hash, "Trying to advertise this file, but the file is already advertised.");
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
                    hashCopied(hash);
                    break;
                default:
                    console.error("Received unknown fileRequest from the Elm app", command);

            }
    });

    // callback to add a file from Fluence network by hash
    app.ports.addFileByHash.subscribe(async (hash) => {

        if (!getConnection()) {
            console.error("Establish connection before adding files.")
            return;
        }

        if (!validateHash(hash)) {
            console.error(`Hash '${hash}' is not valid.`);
            fileLog(hash, `Hash is not valid.`);
            return;
        }

        fileRequested(hash);

        let file = knownFiles[hash];
        if (!!file && file.bytes && file.bytes.length > 0) {
            fileLog(hash, "This file is already known");
        } else {
            let providerName = "IPFS.get_" + hash;

            fileLog(hash, "Trying to discover " + providerName);
            let multiaddrResult = await conn.callProvider(providerName, {}, providerName);

            let multiaddr = multiaddrResult.multiaddr;

            fileLog(hash, "Got multiaddr: " + multiaddr + ", going to download the file");

            fileDownloading(hash);
            let data = await ipfsGet(multiaddr, hash);
            fileLog(hash, "File downloaded from " + multiaddr);

            let preview = getPreview(data);

            fileLoaded(hash, preview);
            knownFiles[hash] = {
                bytes: data,
                multiaddr,
                preview
            };
        }

    });
}

export async function establishConnection(app, target) {
    let errorMsg = "";
    try {
        if (target) {
            let isIp = false;
            if (!target.host) {
                errorMsg = errorMsg + "Host must be present\n"
            } else {
                let addr = new Address4(target.host);
                if (addr.isValid()) {
                    isIp = true
                }
            }

            let port;
            if (!target.pport) {
                errorMsg = errorMsg + "Port must be present\n"
            } else {
                try {
                    port = parseInt(target.pport)
                } catch (e) {
                    errorMsg = errorMsg + "Port must be a number\n"
                }
            }

            if (!target.peerId) {
                errorMsg = errorMsg + "Relay peerId must be present\n"
            } else {
                await PeerId.createFromB58String(target.peerId);
            }

            setRelayPeerId(target.peerId);

            if (errorMsg) {
                peerErrorEvent(errorMsg);
                return;
            }

            let peerId;
            let privateKey;
            if (target.privateKey) {
                peerId = await seedToPeerId(target.privateKey);
                privateKey = target.privateKey;
            } else {
                peerId = await Fluence.generatePeerId();
                privateKey = peerIdToSeed(peerId);
                console.log("PRIVATE KEY GENERATED: " + privateKey)
            }

            relayEvent("relay_connecting");
            let host = null;
            let dns = null;
            if (isIp) {
                host = target.host
            } else {
                dns = target.host
            }
            let relay = {
                host: host,
                pport: port,
                peer: { id: target.peerId, privateKey: null },
                dns: dns
            }
            addRelay(app, relay);

            if (getCurrentPeerId() === peerId) {
                let con = getConnection();
                con.connect(to_multiaddr(relay), relay.peer.id);
            } else {
                setCurrentPeerId(peerId);
                peerEvent("set_peer", {id: peerId.toB58String(), privateKey: privateKey});

                let conn = await Fluence.connect(to_multiaddr(relay), peerId);
                setConnection(app, conn);
            }

            relayEvent("relay_connected", relay);
        }
    } catch (e) {
        console.error(e);
        peerErrorEvent(errorMsg + e.message);
    }
}