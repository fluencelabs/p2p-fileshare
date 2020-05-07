import "regenerator-runtime";
import Hash from 'ipfs-only-hash';
import bs58 from 'bs58';

import Janus from 'janus-beta';
import {genUUID} from "janus-beta/dist/function_call";

import {ipfsAdd, ipfsGet, downloadBlob} from "./fileUtils";

export default async function ports(app) {

  let relays = [
    {peer: {id: "12D3KooWEXNUbCXooUwHrHBbrmjsrpHXoEphPwbjQXEGyzbqKnE9"}, host: "104.248.25.59", pport: 9001},
    {peer: {id: "12D3KooWHk9BjDQBUqnavciRPhAYFvqKBe4ZiPPvde7vDaqgn5er"}, host: "104.248.25.59", pport: 9002},
    {peer: {id: "12D3KooWBUJifCTgaxAUrcM9JysqCcS4CS8tiYH5hExbdWCAoNwb"}, host: "104.248.25.59", pport: 9003},
    {peer: {id: "12D3KooWJbJFaZ3k5sNd8DjQgg3aERoKtBAnirEvPV8yp76kEXHB"}, host: "104.248.25.59", pport: 9004},
    {peer: {id: "12D3KooWCKCeqLPSgMnDjyFsJuWqREDtKNHx1JEBiwaMXhCLNTRb"}, host: "104.248.25.59", pport: 9005},
    {peer: {id: "12D3KooWMhVpgfQxBLkQkJed8VFNvgN4iE6MD7xCybb1ZYWW2Gtz"}, host: "104.248.25.59", pport: 9990},
    {peer: {id: "12D3KooWPnLxnY71JDxvB3zbjKu9k1BCYNthGZw6iGrLYsR1RnWM"}, host: "104.248.25.59", pport: 9100},
  ];

  async function newConnection() {
    let peerId = await Janus.generatePeerId();
    peerEvent("set_peer", {id: peerId.toB58String()});

    // connect to a random node
    let randomNodeNum = Math.floor(Math.random() * relays.length);
    let randomRelay = relays[randomNodeNum];

    let conn = await Janus.connect(randomRelay.peer.id, randomRelay.host, randomRelay.pport, peerId);
    relayEvent("relay_connected", randomRelay);

    return conn;
  }

  let peerEvent = (name, peer) =>
    app.ports.connReceiver.send({event: name, relay: null, peer});
  let relayEvent = (name, relay) =>
    app.ports.connReceiver.send({event: name, peer: null, relay});

  relays.map(d => relayEvent("relay_discovered", d));

  let conn = await newConnection();


  /**
   * Handle connection commands
   */
  app.ports.connRequest.subscribe(async ({command, id}) => {
    switch (command) {
      case "set_relay":
        let relay = relays.find(r => r.peer.id === id);
        if (relay) {
          // if the connection already established, connect to another node and save previous services and subscriptions
          await conn.connect(relay.peer.id, relay.host, relay.pport);
          relayEvent("relay_connected", relay);
        }

        break;

      default:
        console.error("Received unknown connRequest from the Elm app", command);
    }
  });

  /**
   * Handle file commands, sending events
   */

  let emptyFileEvent = {log:null, data:[]};
  let sendToFileReceiver = ev => {
    app.ports.fileReceiver.send({...emptyFileEvent, ...ev});
  };

  let fileAdvertised = (hash) =>
    sendToFileReceiver({event: "advertised", hash});
  let fileAsked = (hash) =>
    sendToFileReceiver({event: "asked", hash});
  let fileRequested = (hash) =>
    sendToFileReceiver({event: "requested", hash});
  let fileLoaded = (hash, data) =>
    sendToFileReceiver({event: "loaded", data, hash});
  let fileLog = (hash, log) =>
    sendToFileReceiver({event: "log", hash, log});

  let multiaddrService = "IPFS.multiaddr";

  let knownFiles = {};

  async function handleFileRequests({command, hash}) {
    // TODO Queue, and handle commands once (re)connected
    if(!conn) console.error("Cannot handle fileRequest when not connected");
    else
      switch (command) {
        case "download":
          let fileDownload = knownFiles[hash];
          if(!!fileDownload && (fileDownload.bytes && fileDownload.bytes.length > 0)) {
            downloadBlob(fileDownload.bytes, hash, 'application/octet-stream');
          } else console.error("Cannot download as file is unknown for hash: "+hash);
          break;

        case "advertise":

          let fileAdv = knownFiles[hash];
          if(!!fileAdv && (fileAdv.bytes && fileAdv.bytes.length > 0) || fileAdv.multiaddr) {

            let serviceName = "IPFS.get_" + hash;

            fileLog(hash, "Going to advertise");
            await conn.registerService(serviceName, async fc => {
              fileLog(hash, "File asked");
              fileAsked(hash);

              let replyWithMultiaddr = async (multiaddr) =>
                  await conn.sendMessage(fc.reply_to, {msg_id: fc.arguments.msg_id, multiaddr});

              // check cache
              if(fileAdv.multiaddr) {
                await replyWithMultiaddr(fileAdv.multiaddr)
              } else {

                // call multiaddr
                let msgId = genUUID();

                let multiaddrResult = await conn.sendServiceCallWaitResponse(multiaddrService, {msg_id: msgId}, (args) => args.msg_id && args.msg_id === msgId);
                let multiaddr = multiaddrResult.multiaddr;
                // upload a file
                console.log("going to upload");
                await ipfsAdd(multiaddr, fileAdv.bytes);
                fileLog(hash, "File uploaded to "+multiaddr);
                fileAdv.multiaddr = multiaddr;
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
  }

  app.ports.fileRequest.subscribe(handleFileRequests);

  function validateHash(hash) {
    if (typeof hash === "string" && hash.length === 46 && hash.substring(0, 2) === "Qm"){
      try {
        bs58.decode(hash);
        return true;
      } catch (e) {
        console.error(`Cannot decode hash '${hash}': ${e}`)
      }
    }

    return false;
  }

  app.ports.addFileByHash.subscribe(async (hash) => {

    if (!validateHash(hash)) {
      console.error(`Hash '${hash}' is not valid.`);
      fileLog(hash, `Hash is not valid.`);
      return;
    }

    // TODO verify that hash is a valid IPFS hash
    fileRequested(hash);

    let file = knownFiles[hash];

    if(!!file && file.bytes && file.bytes.length > 0) {
      fileLog(hash, "This file is already known");

    } else {

      let msgId = genUUID();
      let serviceName = "IPFS.get_" + hash;

      fileLog(hash, "Trying to discover " + serviceName + ", msg_id=" + msgId);
      let multiaddrResult = await conn.sendServiceCallWaitResponse(serviceName, {msg_id: msgId}, (args) => args.msg_id && args.msg_id === msgId);
      let multiaddr = multiaddrResult.multiaddr;

      fileLog(hash, "Got multiaddr: " + multiaddr + ", going to download the file");

      let data = await ipfsGet(multiaddr, hash);
      fileLog(hash, "File downloaded from " + multiaddr);

      fileLoaded(hash, Array.from(data));
      knownFiles[hash] = {
        bytes: data,
        multiaddr
      };
    }

  });

  async function addFileToCache(fileBytesArray) {
    let h = await Hash.of(fileBytesArray);

    knownFiles[h] = {bytes:Uint8Array.from(fileBytesArray)};

    app.ports.hashReceiver.send(h);
  }

  app.ports.calcHash.subscribe(addFileToCache);




  async function advertiseFileAndDisconnect(seed) {
    let conn = await newConnection();

    let bytes = [];

    for (let step = 0; step < seed; step++) {
      let byte = step % 254;
      bytes.push(byte)
    }
    let newBytes = Uint8Array.from(bytes);

    let h = await Hash.of(newBytes);

    knownFiles[h] = {bytes:Uint8Array.from(newBytes)};

    app.ports.hashReceiver.send(h);

    await handleFileRequests({command: "advertise", hash: h});
    await conn.connection.disconnect();
  }


  return {step: advertiseFileAndDisconnect};
}