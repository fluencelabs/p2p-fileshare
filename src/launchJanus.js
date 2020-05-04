import "regenerator-runtime";
import Hash from 'ipfs-only-hash';

import {Janus, JanusClient} from 'janus-beta';
import {genUUID} from "janus-beta/dist/function_call";

import {imageType, ipfsAdd, ipfsGet, downloadBlob} from "./fileUtils";

export async function launchJanus(app) {

  let relays = [
    {peer: {id: "QmVL33cyaaGLWHkw5ZwC7WFiq1QATHrBsuJeZ2Zky7nDpz"}, host: "134.209.186.43", pport: 9001},
    {peer: {id: "QmVzDnaPYN12QAYLDbGzvMgso7gbRD9FQqRvGZBfeKDSqW"}, host: "134.209.186.43", pport: 9002},
  ];

  let peerEvent = (name, peer) =>
    app.ports.connReceiver.send({event: name, relay: null, peer});
  let relayEvent = (name, relay) =>
    app.ports.connReceiver.send({event: name, peer: null, relay});

  relays.map(d => relayEvent("relay_discovered", d));


  let conn = null;

  let connect = async (relay) => {
    let privateKey = await Janus.generatePrivateKey();
    conn = await Janus.connect(relay.peer.id, relay.host, relay.pport, privateKey);

    peerEvent("set_peer", {id: conn.selfPeerIdStr});
    relayEvent("relay_connected", relay);
  };

  await connect( relays[0] );

  /**
   * Handle connection commands
   */
  app.ports.connRequest.subscribe(async ({command, id}) => {
    if (command === "set_relay") {
      let relay = relays.find(r => r.peer.id === id);
      relay && await connect(relay);
    } else {
      console.error("Received unknown connRequest from the Elm app", command);
    }
  });

  /**
   * Handle file commands, sending events
   */

  let emptyFileEvent = {log:null, data:[], imageType:null};
  let sendToFileReceiver = ev =>
    app.ports.fileReceiver.send({...ev, ...emptyFileEvent});

  let fileAdvertised = (hash) =>
    sendToFileReceiver({event: "advertised", hash});
  let fileAsked = (hash) =>
    sendToFileReceiver({event: "asked", hash});
  let fileRequested = (hash) =>
    sendToFileReceiver({event: "requested", hash});
  let fileLoaded = (hash, data, imageType) =>
    sendToFileReceiver({event: "loaded", data, hash, imageType});
  let fileLog = (hash, log) =>
    sendToFileReceiver({event: "log", hash, log});

  let knownFiles = {};

  app.ports.fileRequest.subscribe(async ({command, hash}) => {
    // TODO Queue, and handle commands once (re)connected
    if(!conn) console.error("Cannot handle fileRequest when not connected");
    else
      switch (command) {
        case "download":
          if(!!knownFiles[hash] && (knownFiles[hash].bytes && knownFiles[hash].bytes.length > 0)) {
            downloadBlob(knownFiles[hash].bytes, hash, 'application/octet-stream');
          } else console.error("Cannot download as file is unknown for hash: "+hash);
          break;

        case "advertise":

          if(!!knownFiles[hash] && (knownFiles[hash].bytes && knownFiles[hash].bytes.length > 0) || knownFiles[hash].multiaddr) {

              let serviceName = "IPFS.get_" + hash;

              fileLog(hash, "Going to advertise");
              await conn.registerService(serviceName, async fc => {
                fileLog(hash, "File asked");
                fileAsked(hash);

                let replyWithMultiaddr = async (multiaddr) =>
                  await conn.sendMessage(fc.reply_to, {msg_id: fc.arguments.msg_id, multiaddr});

                // check cache
                if(knownFiles[hash].multiaddr) {
                  await replyWithMultiaddr(knownFiles[hash].multiaddr)
                } else {

                  // call multiaddr
                  let msgId = genUUID();

                  let multiaddrResult = await conn.sendServiceCallWaitResponse("IPFS.multiaddr", {msg_id: msgId}, (args) => args.msg_id && args.msg_id === msgId);
                  let multiaddr = multiaddrResult.multiaddr;
                  // upload a file
                  console.log("going to upload");
                  await ipfsAdd(multiaddr, knownFiles[hash].bytes);
                  fileLog(hash, "File uploaded to "+multiaddr);
                  knownFiles[hash].multiaddr = multiaddr;
                  // send back multiaddr
                  await replyWithMultiaddr(multiaddr);
                }

              });
              fileLog(hash, "File advertised on Fluence network");
              fileAdvertised(hash);

          } else {
            fileLog(hash, "This file is unknown, or no data known");
          }

          break;


        default:
          console.error("Received unknown fileRequest from the Elm app", command);

      }
  });



  app.ports.addFileByHash.subscribe(async (hash) => {
    // TODO verify that hash is a valid IPFS hash
    fileRequested(hash);

    if(!!knownFiles[hash] && knownFiles[hash].bytes && knownFiles[hash].bytes.length > 0) {
      fileLog(hash, "This file is already known");

    } else {

      let msgId = genUUID();
      let serviceName = "IPFS.get_" + hash;
      await conn.sendServiceCall("IPFS.get_" + hash, {msg_id: msgId});

      fileLog(hash, "Trying to discover " + serviceName + ", msg_id=" + msgId);
      let multiaddrResult = await conn.sendServiceCallWaitResponse("IPFS.get_" + hash, {msg_id: msgId}, (args) => args.msg_id && args.msg_id === msgId);
      let multiaddr = multiaddrResult.multiaddr;

      fileLog(hash, "Got multiaddr: " + multiaddr + ", going to download the file");

      let data = await ipfsGet(multiaddr, hash);
      fileLog(hash, "File downloaded from " + multiaddr);

      fileLoaded(hash, Array.from(data), imageType(data));
      knownFiles[hash] = {
        bytes: data,
        multiaddr
      };
    }

  });


  app.ports.calcHash.subscribe(async (fileBytesArray) => {
    let h = await Hash.of(fileBytesArray);

    knownFiles[h] = {bytes:Uint8Array.from(fileBytesArray)};

    app.ports.hashReceiver.send(h);
  });


}