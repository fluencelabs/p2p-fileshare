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

import Fluence from 'fluence';
import {establishConnection, initAdmin, sendEventToNetworkMap} from "./admin"

import {peerEvent, relayEvent} from "./connectionReceiver";

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

// call if we found out about any peers or relays in Fluence network
export function peerAppearedEvent(app, peer, peerType, updateDate) {
    let peerAppeared = { peer: {id: peer}, peerType, updateDate};
    sendEventToNetworkMap({event: "peer_appeared", peerAppeared})
}

export default async function ports(app) {

    setApp(app)
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
}