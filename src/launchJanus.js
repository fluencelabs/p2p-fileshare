import {JanusClient} from 'janus-beta';
import {FunctionCall, genUUID, makeFunctionCall} from "janus-beta/dist/function_call";

export async function launchJanus(app) {

  let relays = [
    {peer: {id: "QmVL33cyaaGLWHkw5ZwC7WFiq1QATHrBsuJeZ2Zky7nDpz"}, host: "104.248.25.59", pport: 9001},
    {peer: {id: "QmVzDnaPYN12QAYLDbGzvMgso7gbRD9FQqRvGZBfeKDSqW"}, host: "104.248.25.59", pport: 9002},
  ]

  let peerEvent = (name, peer) =>
    app.ports.connReceiver.send({event: name, relay: null, peer});
  let relayEvent = (name, relay) =>
    app.ports.connReceiver.send({event: name, peer: null, relay});

  relays.map(d => relayEvent("relay_discovered", d));

  let connect = async (relay) => {
    // connect to two different nodes
    let conn = await JanusClient.connect(relay.peer.id, relay.host, relay.pport);

    peerEvent("set_peer", {id: conn.selfPeerIdStr});
    relayEvent("relay_connected", relay);
  }

  await connect( relays[0] );

  app.ports.connRequest.subscribe(async ({command, id}) => {
    switch (command) {
      case "set_relay":
        let relay = relays.find(r => r.peer.id === id)
        relay && await connect(relay);

        break;

      case _:
        console.error("Received unknown conRequest from Elm app", command);
    }
  })
}