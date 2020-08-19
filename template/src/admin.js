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
    app.ports.wasmUploaderReceiver.send(event)
}

export function sendEventToAvailableModules(ev) {
    let event = {...emptyNetworkMapEvent, ...ev}
    app.ports.availableModulesReceiver.send(event)
}

export function initAdmin(adminApp) {
    app = adminApp;

    app.ports.availableModulesRequest.subscribe(async ({command, id}) => {
        let conn = getConnection();
        if (!conn) console.error("Cannot handle interfacesRequest when not connected");
        else {
            switch (command) {
                case "get_modules":

                    let modules = await conn.getAvailableModules(id);
                    sendEventToAvailableModules({event: "set_modules", id: id, modules: modules});

                    break;
            }
        }
    });

    app.ports.selectWasm.subscribe(async ({command, id, name}) => {
        let conn = getConnection();
        if (!conn) console.error("Cannot handle interfacesRequest when not connected");
        else {
            switch (command) {
                case "upload_wasm":
                    if (name) {
                        console.error("'name' is empty")
                    }
                    let input = document.createElement('input');
                    input.type = 'file';

                    input.onchange = async e => {
                        let file = e.target.files[0];
                        let arrayBuffer = await file.arrayBuffer();
                        let array = new Uint8Array(arrayBuffer);

                        let base64 = Buffer.from(array).toString('base64');
                        await conn.addModule(base64, name, 100, [], undefined, [], id);

                        sendEventToWasmUploader({event: "wasm_uploaded", id: id});
                    }

                    input.click();

                    break;
            }
        }
    });

    app.ports.createServiceRequest.subscribe(async ({command, id, modules}) => {
        let conn = getConnection();
        if (!conn) console.error("Cannot handle interfacesRequest when not connected");
        else {
            switch (command) {
                case "create_service":
                    let serviceId = await conn.createService(id, modules);
                    let createdInterface = await conn.getInterface(serviceId, id);
                    sendEventToInterface({event: "add_interfaces", interfaces: [createdInterface], id: id});
                    break;
            default:
                console.error("Received unknown interfacesRequest from the Elm app", command);
            }
        }

    });

    app.ports.interfacesRequest.subscribe(async ({command, id, call}) => {
        let conn = getConnection();
        if (!conn) console.error("Cannot handle interfacesRequest when not connected");
        else {
            let result;
            switch (command) {
                case "get_active_interfaces":
                    result = await conn.getActiveInterfaces(nodePeer);
                    sendEventToInterface({event: "add_interfaces", interfaces: result, id: nodePeer});
                    break;
                case "get_interface":
                    // TODO
                    result = await conn.getInterface(serviceId, nodePeer);

                    break;
                case "call":
                    result = await conn.callService(id, call.serviceId, call.moduleName, call.args, call.fname);

                    const callResult = {
                        serviceId: call.serviceId,
                        moduleName: call.moduleName,
                        fname: call.fname,
                        result: JSON.stringify(result, undefined, 2)
                    };
                    sendEventToInterface({event: "add_result", result: callResult, id: id});

                    break;
                default:
                    console.error("Received unknown interfacesRequest from the Elm app", command);
            }
        }

    });
}