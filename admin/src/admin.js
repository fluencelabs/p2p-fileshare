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
    setConnection,
    setCurrentPeerId,
    to_multiaddr
} from "./ports";
import {TrustGraph} from "fluence/dist/trust/trust_graph";
import {nodeRootCert} from "fluence/dist/trust/misc";
import {issue} from "fluence/dist/trust/certificate";
import {peerErrorEvent, peerEvent, relayEvent} from "./connectionReceiver";
import {interfacesRequest, servicesRequest} from "../../src/handlers";

let Address4 = require('ip-address').Address4;

let rootCert;
let trustGraph;
let app;
let relayPeerId;

export function getRelayPeerId() {
    return relayPeerId
}

export function setRelayPeerId(peerId) {
    relayPeerId = peerId
}

function getRootCert() {
    return rootCert;
}

function setRootCert(newCert) {
    rootCert = newCert
}

let emptyNetworkMapEvent = {certs: null, id: null, interfaces: null, result: null, peerAppeared: null, wasmUploaded: null, modules: null};

export function sendEventToNetworkMap(ev) {
    let event = {...emptyNetworkMapEvent, ...ev}
    app.ports.networkMapReceiver.send(event)
}

function sendCerts(id, certs) {
    let decoded = certs.map((cert) => {
        cert.chain = cert.chain.map((t) => {
            let copied = {...t}
            copied.issuedFor = t.issuedFor.toB58String();
            return copied;
        })

        return cert;
    })

    sendEventToNetworkMap({event: "add_cert", certs: decoded, id: id});
}

export function initAdmin(adminApp) {
    app = adminApp;

    app.ports.servicesRequest.subscribe(async ({command, id, modules, name}) => {
        let conn = getConnection();
        await servicesRequest(conn, id, command, modules, name, sendEventToNetworkMap, sendEventToNetworkMap, sendEventToNetworkMap)
    });

    app.ports.interfacesRequest.subscribe(async ({command, id, call}) => {
        let conn = getConnection();
        await interfacesRequest(conn, command, id, call, sendEventToNetworkMap);

    });

    app.ports.certificatesRequest.subscribe(async ({command, id}) => {
        let cert;
        if (!getConnection()) console.error("Cannot handle certificatesRequest when not connected");
        else
            switch (command) {
                case "issue":
                    cert = await addCertificate(id);
                    sendCerts(id, [cert])
                    break;
                case "get_cert":
                    let certs = await getCertificates(id);
                    sendCerts(id, certs)
                    break;
                default:
                    console.error("Received unknown fileRequest from the Elm app", command);

            }
    });
}

export async function getCertificates(peerId) {
    let conn = getConnection();

    if (!trustGraph) {
        trustGraph = new TrustGraph(conn);
    }

    return await trustGraph.getCertificates(peerId);
}

export async function addCertificate(peerId) {
    let conn = getConnection();

    if (!trustGraph) {
        trustGraph = new TrustGraph(conn);
    }

    if (!rootCert) {
        setRootCert(await nodeRootCert(conn.selfPeerInfo.id));
        await trustGraph.publishCertificates(conn.selfPeerInfo.id.toB58String(), [rootCert]);
    }

    let issuedAt = new Date();
    let expiresAt = new Date();
    expiresAt.setMonth(expiresAt.getMonth() + 1);

    let issuedCert = await issue(conn.selfPeerInfo.id, PeerId.createFromB58String(peerId), getRootCert(), expiresAt.getTime(), issuedAt.getTime());
    await trustGraph.publishCertificates(peerId, [issuedCert]);
    return issuedCert;
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