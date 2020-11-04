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

import {
    getConnection, nodePeer

} from "./ports";
import {interfacesRequest, servicesRequest} from "../../src/handlers";

let app;
let relayPeerId;

export function getRelayPeerId() {
    return relayPeerId
}

export function setRelayPeerId(peerId) {
    relayPeerId = peerId
}

let emptyNetworkMapEvent = {certs: null, id: null, interfaces: null, result: null, peerAppeared: null, wasmUploaded: null, modules: null};

export function sendEventToInterface(ev) {
    let event = {...emptyNetworkMapEvent, ...ev}
    app.ports.interfaceReceiver.send(event)
}

export function sendEventToWasmUploader(ev) {
    let event = {...emptyNetworkMapEvent, ...ev}
    app.ports.servicesReceiver.send(event)
}

export function sendEventToAvailableModules(ev) {
    let event = {...emptyNetworkMapEvent, ...ev}
    app.ports.interfaceReceiver.send(event)
}

export function initAdmin(adminApp) {
    app = adminApp;

    app.ports.servicesRequest.subscribe(async ({command, modules, name, wasmUploaded}) => {
        let id = nodePeer;
        let conn = getConnection();
        await servicesRequest(conn, id, command, modules, name, sendEventToAvailableModules, sendEventToInterface, sendEventToWasmUploader);
    });

    app.ports.interfacesRequest.subscribe(async ({command, id, call}) => {
        let conn = getConnection();
        await interfacesRequest(conn, command, id, call, sendEventToInterface);

    });
}