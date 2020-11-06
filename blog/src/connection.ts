import * as PeerId from "peer-id";
import {peerIdToSeed, seedToPeerId} from "fluence/dist/seed";
import Fluence from "fluence";
import {
    addRelay, getApp,
    peerErrorEvent, peerEvent, Relay,
    relayEvent
} from "./ports";
import {to_multiaddr} from "./utils";

let Address4 = require('ip-address').Address4;

let relayMultiaddr: string | undefined = undefined
let peerId: PeerId | undefined = undefined

export function getRelayMultiaddr(): string {
    return relayMultiaddr
}

export function getPeerId(): PeerId {
    return peerId
}

function setRelayMultiaddr(newRelay: string) {
    relayMultiaddr = newRelay
}

function setPeerId(newPeerId: PeerId) {
    peerId = newPeerId
}

export interface Target {
    host: string,
    pport: string,
    peerId: string,
    privateKey: string
}

export async function establishConnection(app: any, target: Target) {
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
            let relay: Relay = {
                host: host,
                pport: port,
                peer: {id: target.peerId, privateKey: null},
                dns: dns
            }
            addRelay(app, relay);

            setPeerId(peerId);
            setRelayMultiaddr(to_multiaddr(relay))

            relayEvent("relay_connected", relay);
        }
    } catch (e) {
        console.error(e);
        peerErrorEvent(errorMsg + e.message);
    }
}

export const connectionHandler = async ({command, id, connectTo}: { command: string, id: string, connectTo: Target }) => {
    switch (command) {
        case "generate_peer":
            let peerId = await Fluence.generatePeerId();
            let peerIdStr = peerId.toB58String();
            peerEvent("set_peer", {id: peerIdStr});
            break;

        case "connect_to":
            await establishConnection(getApp(), connectTo);

            break;

        default:
            console.error("Received unknown connRequest from the Elm app", command);
    }
}