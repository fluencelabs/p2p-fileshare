export async function servicesRequest(conn, id, command, modules, name, sendEventToAvailableModules, sendEventToInterface, sendEventToWasmUploader) {
    if (!conn) console.error("Cannot handle interfacesRequest when not connected");
    else {
        switch (command) {
            case "get_modules":

                let receivedModules = await conn.getAvailableModules(id);
                sendEventToAvailableModules({event: "set_modules", id: id, modules: receivedModules});

                break;
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

            case "create_service":
                let serviceId = await conn.createService(id, modules);
                let createdInterface = await conn.getInterface(serviceId, id);
                sendEventToInterface({event: "add_interfaces", interfaces: [createdInterface], id: id});
                break;
            default:
                console.error("Received unknown interfacesRequest from the Elm app", command);

        }
    }
}

export async function interfacesRequest(conn, command, id, call, sendEventToInterface) {
    if (!conn) console.error("Cannot handle interfacesRequest when not connected");
    else {
        let result;
        switch (command) {
            case "get_active_interfaces":
                result = await conn.getActiveInterfaces(id);
                sendEventToInterface({event: "add_interfaces", interfaces: result, id: id});
                break;
            case "get_interface":
                // TODO
                result = await conn.getInterface(serviceId, id);

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
}