import * as PeerId from "peer-id";
import {peerIdToSeed, seedToPeerId} from "fluence/dist/seed";
import Fluence from "fluence";
import {
    addRelay, getApp,
    getConnection,
    getCurrentPeerId, getRelays,
    peerErrorEvent, peerEvent, Relay,
    relayEvent, setConnection, setCurrentPeerId,
    setRelayPeerId
} from "./ports";
import {to_multiaddr} from "./utils";
let Address4 = require('ip-address').Address4;

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
            let relay: Relay = {
                host: host,
                pport: port,
                peer: { id: target.peerId, privateKey: null },
                dns: dns
            }
            addRelay(app, relay);

            if (getCurrentPeerId() === peerId) {
                let con = getConnection();
                await con.connect(to_multiaddr(relay));
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

export const connectionHandler = async ({command, id, connectTo}: {command: string, id: string, connectTo: Target}) => {
    switch (command) {
        case "set_relay":
            let relay = getRelays().find(r => r.peer.id === id);
            if (relay) {
                if (!getCurrentPeerId()) {
                    break;
                }

                relayEvent("relay_connecting");
                let conn = getConnection()
                // if the connection already established, connect to another node and save previous services and subscriptions
                if (conn) {
                    await conn.connect(to_multiaddr(relay));
                } else {
                    setConnection(getApp(), await Fluence.connect(to_multiaddr(relay), getCurrentPeerId()));
                }

                relayEvent("relay_connected", relay);
            }

            break;

        case "generate_peer":
            let peerId = await Fluence.generatePeerId();
            setCurrentPeerId(peerId);
            let peerIdStr = peerId.toB58String();
            peerEvent( "set_peer", {id: peerIdStr});
            break;

        case "connect_to":
            await establishConnection(getApp(), connectTo);

            break;

        default:
            console.error("Received unknown connRequest from the Elm app", command);
    }
}