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

import * as PeerId from "peer-id";
import {peerIdToSeed, seedToPeerId} from "fluence/dist/seed";
import Fluence from "fluence";
import {
    addRelay, getConnection,
    getCurrentPeerId,
    peerErrorEvent,
    peerEvent,
    relayEvent,
    setConnection,
    setCurrentPeerId,
    to_multiaddr
} from "./ports";

let Address4 = require('ip-address').Address4;

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

            if (errorMsg) {
                peerErrorEvent(app, errorMsg);
                return;
            }

            let peerId;
            let seed;
            if (target.seed) {
                peerId = await seedToPeerId(target.seed);
                seed = target.seed;
            } else {
                peerId = await Fluence.generatePeerId();
                seed = peerIdToSeed(peerId);
                console.log("SEED GENERATED: " + seed)
            }

            relayEvent(app, "relay_connecting");
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
                peer: { id: target.peerId, seed: null },
                dns: dns
            }
            addRelay(app, relay);

            if (getCurrentPeerId() === peerId) {
                let con = getConnection();
                con.connect(to_multiaddr(relay), relay.peer.id);
            } else {
                setCurrentPeerId(peerId);
                peerEvent(app, "set_peer", {id: peerId.toB58String(), seed});

                let conn = await Fluence.connect(to_multiaddr(relay), peerId);
                setConnection(app, conn);
            }

            relayEvent(app,"relay_connected", relay);
        }
    } catch (e) {
        console.log(e);
        peerErrorEvent(app,errorMsg + e.message);
    }
}