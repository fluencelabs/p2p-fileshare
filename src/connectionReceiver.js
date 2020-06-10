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

// event with an error message
import {getApp} from "./ports";

export function peerErrorEvent(errorMsg) {
    getApp().ports.connReceiver.send({event: "error", relay: null, peer: null, errorMsg});
}

// new peer is generated
export function peerEvent(name, peer) {
    let peerToSend = {privateKey: null, ...peer};
    getApp().ports.connReceiver.send({event: name, relay: null, errorMsg: null, peer: peerToSend});
}

export function convertRelayForELM(relay) {
    let host;
    if (relay.host) {
        host = relay.host;
    } else {
        host = relay.dns;
    }
    return {host: host, peer: relay.peer, pport: relay.pport};
}

// new relay connection established
export function relayEvent(name, relay) {
    let relayToSend = null;
    if (relay) {
        relayToSend = convertRelayForELM(relay)
    }
    let ev = {event: name, peer: null, errorMsg: null, relay: relayToSend};
    getApp().ports.connReceiver.send(ev);
}