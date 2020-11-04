import * as PeerId from "peer-id";
import {peerIdToSeed, seedToPeerId} from "fluence/dist/seed";
import Fluence from "fluence";
import {FluenceClient} from "fluence/dist/fluenceClient";
let Address4 = require('ip-address').Address4;

interface Peer {
    id: string,
    privateKey?: string
}

interface Relay {
    host?: string,
    pport: number,
    peer: Peer,
    dns?: string
}

export function getRelays() {
    return relays1;
}

interface Target {
    host: string,
    pport: string,
    peerId: string,
    privateKey: string
}

export function peerErrorEvent(errorMsg: string) {
    getApp().ports.connReceiver.send({event: "error", relay: null, peer: null, errorMsg});
}

interface ElmRelay {
    peer: Peer,
    host: string,
    pport: number
}

let relays1: Relay[] = [
    {peer: {id: "12D3KooWEXNUbCXooUwHrHBbrmjsrpHXoEphPwbjQXEGyzbqKnE9", privateKey: null}, dns: "138.197.177.2", pport: 9001},
    {peer: {id: "12D3KooWHk9BjDQBUqnavciRPhAYFvqKBe4ZiPPvde7vDaqgn5er", privateKey: null}, dns: "138.197.177.2", pport: 9002},
    {peer: {id: "12D3KooWBUJifCTgaxAUrcM9JysqCcS4CS8tiYH5hExbdWCAoNwb", privateKey: null}, dns: "138.197.177.2", pport: 9003}
];

export function convertRelayForELM(relay: Relay): ElmRelay {
    let host;
    if (relay.host) {
        host = relay.host;
    } else {
        host = relay.dns;
    }
    return {host: host, peer: relay.peer, pport: relay.pport};
}

export function to_multiaddr(relay: Relay) {
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

export function addRelay(app: any, relay: Relay) {
    // TODO: if the same peerId with different ip addresses?
    if (!relays1.find(r => r.peer.id === relay.peer.id)) {
        relayEvent("relay_discovered", relay)
        relays1.push(relay)
    }
}

interface RelayEvent {
    event: string,
    peer: string,
    errorMsg: string,
    relay: ElmRelay
}

export function relayEvent(name: string, relay?: Relay) {
    let relayToSend = null;
    if (relay) {
        relayToSend = convertRelayForELM(relay)
    }
    let ev: RelayEvent = {event: name, peer: null, errorMsg: null, relay: relayToSend};
    getApp().ports.connReceiver.send(ev);
}

export function setConnection(app: any, connection: FluenceClient) {
    conn = connection;
}

export function getConnection() {
    return conn
}

let app: any;
let relayPeerId: string;
let currentPeerId: PeerId
let conn: FluenceClient

// new peer is generated
export function peerEvent(name: string, peer: Peer) {
    let peerToSend: Peer = {privateKey: null, ...peer};
    getApp().ports.connReceiver.send({event: name, relay: null, errorMsg: null, peer: peerToSend});
}

export function getCurrentPeerId() {
    return currentPeerId
}

export function setCurrentPeerId(peerId: PeerId) {
    currentPeerId = peerId;
}

export function setApp(newApp: any) {
    app = newApp
}

export function getApp(): any {
    return app;
}

export function setRelayPeerId(peerId: string) {
    relayPeerId = peerId
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

let f = async ({command, id, connectTo}: {command: string, id: string, connectTo: Target}) => {
    switch (command) {
        case "set_relay":
            let relay = relays1.find(r => r.peer.id === id);
            if (relay) {
                if (!getCurrentPeerId()) {
                    break;
                }

                relayEvent("relay_connecting");
                // if the connection already established, connect to another node and save previous services and subscriptions
                if (conn) {
                    await conn.connect(to_multiaddr(relay));
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
            console.log("ALALALALL")
            await establishConnection(app, connectTo);

            break;

        default:
            console.error("Received unknown connRequest from the Elm app", command);
    }
}

export default async function ports(app: any) {

    setApp(app)

    /**
     * Handle connection commands
     */
    app.ports.connRequest.subscribe(f);
}
