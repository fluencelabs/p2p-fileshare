import {ElmRelay, Relay} from "./ports";

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
