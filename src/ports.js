import "regenerator-runtime";
import Hash from 'ipfs-only-hash';
import bs58 from 'bs58';

import Fluence from 'fluence';
import {genUUID} from "fluence/dist/function_call";

import {ipfsAdd, ipfsGet, downloadBlob, getImageType} from "./fileUtils";

export default async function ports(app) {

  let relays = [
    {peer: {id: "12D3KooWEXNUbCXooUwHrHBbrmjsrpHXoEphPwbjQXEGyzbqKnE9"}, dns: "relay01.fluence.dev", pport: 19001},
    {peer: {id: "12D3KooWHk9BjDQBUqnavciRPhAYFvqKBe4ZiPPvde7vDaqgn5er"}, dns: "relay01.fluence.dev", pport: 19002},
    {peer: {id: "12D3KooWBUJifCTgaxAUrcM9JysqCcS4CS8tiYH5hExbdWCAoNwb"}, dns: "relay01.fluence.dev", pport: 19003},
    {peer: {id: "12D3KooWJbJFaZ3k5sNd8DjQgg3aERoKtBAnirEvPV8yp76kEXHB"}, dns: "relay01.fluence.dev", pport: 19004},
    {peer: {id: "12D3KooWCKCeqLPSgMnDjyFsJuWqREDtKNHx1JEBiwaMXhCLNTRb"}, dns: "relay01.fluence.dev", pport: 19005},
    {peer: {id: "12D3KooWMhVpgfQxBLkQkJed8VFNvgN4iE6MD7xCybb1ZYWW2Gtz"}, dns: "relay01.fluence.dev", pport: 19990},
    {peer: {id: "12D3KooWPnLxnY71JDxvB3zbjKu9k1BCYNthGZw6iGrLYsR1RnWM"}, dns: "relay01.fluence.dev", pport: 19100},
  ];

  let emptyRelay = {
    dns: null,
    host: null
  };
  let peerEvent = (name, peer) =>
    app.ports.connReceiver.send({event: name, relay: null, peer});
  let relayEvent = (name, relay) => {
    let relayToSend = {...emptyRelay, ...relay};
    let ev = {event: name, peer: null, relay: relayToSend};
    console.log(ev);
    app.ports.connReceiver.send(ev);
  };

  relays.map(d => relayEvent("relay_discovered", d));

  let peerId = await Fluence.generatePeerId();
  peerEvent("set_peer", {id: peerId.toB58String()});

  // connect to a random node
  let randomNodeNum = Math.floor(Math.random() * relays.length);
  let randomRelay = relays[randomNodeNum];

  let host;
  let protocol;
  if (randomRelay.host) {
      host = "/ip4/" + randomRelay.host
      protocol = "ws"
  } else {
      host = "/dns4/" + randomRelay.dns;
      protocol = "wss"
  }
  let multiaddr = `${host}/tcp/${randomRelay.pport}/${protocol}/p2p/${randomRelay.peer.id}`;

  let conn = await Fluence.connect(multiaddr, peerId);
  relayEvent("relay_connected", randomRelay);

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

  let emptyFileEvent = {log:null, preview: null};
  let sendToFileReceiver = ev => {
    app.ports.fileReceiver.send({...emptyFileEvent, ...ev});
  };

  let fileAdvertised = (hash, preview) =>
    sendToFileReceiver({event: "advertised", hash, preview});
  let fileUploading = (hash) =>
      sendToFileReceiver({event: "uploading", hash});
  let fileUploaded = (hash) =>
      sendToFileReceiver({event: "uploaded", hash});
  let fileDownloading = (hash) =>
      sendToFileReceiver({event: "downloading", hash});
  let fileAsked = (hash) =>
    sendToFileReceiver({event: "asked", hash});
  let fileRequested = (hash) =>
    sendToFileReceiver({event: "requested", hash});
  let fileLoaded = (hash, preview) =>
    sendToFileReceiver({event: "loaded", hash, preview});
  let fileLog = (hash, log) =>
    sendToFileReceiver({event: "log", hash, log});

  let multiaddrService = "IPFS.multiaddr";

  let knownFiles = {};

  app.ports.selectFile.subscribe(async () => {
    var input = document.createElement('input');
    input.type = 'file';

    input.onchange = async e => {
      let file = e.target.files[0];
      let arrayBuffer = await file.arrayBuffer();
      let array = new Uint8Array(arrayBuffer);

      let hash = await Hash.of(array);

      if(!knownFiles[hash]) {

        fileRequested(hash);

        let previewStr = getPreview(array);

        knownFiles[hash] = {bytes:array, preview: previewStr};

        let serviceName = "IPFS.get_" + hash;

        fileLog(hash, "Going to advertise");
        fileLoaded(hash, previewStr);
        await conn.registerService(serviceName, async fc => {
          fileLog(hash, "File asked");

          let replyWithMultiaddr = async (multiaddr) =>
              await conn.sendCall(fc.reply_to, {msg_id: fc.arguments.msg_id, multiaddr});

          // check cache
          if(knownFiles[hash].multiaddr) {
            await replyWithMultiaddr(knownFiles[hash].multiaddr)
          } else {

            // call multiaddr
            let msgId = genUUID();

            let multiaddrResult = await conn.sendServiceCallWaitResponse(multiaddrService, {msg_id: msgId}, (args) => args.msg_id && args.msg_id === msgId);
            let multiaddr = multiaddrResult.multiaddr;
            // upload a file
            console.log("going to upload");
            fileUploading(hash);
            await ipfsAdd(multiaddr, knownFiles[hash].bytes);
            fileUploaded(hash);
            fileLog(hash, "File uploaded to "+multiaddr);
            knownFiles[hash].multiaddr = multiaddr;
            // send back multiaddr
            await replyWithMultiaddr(multiaddr);
          }

          fileAsked(hash);

        });
        fileLog(hash, "File advertised on Fluence network");

        fileAdvertised(hash, previewStr);

      } else {
        console.log("This file is already advertised.");
        fileLog(hash, "Trying to advertise this file, but the file is already advertised.");
      }
    };

    input.click();
  });

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

        default:
          console.error("Received unknown fileRequest from the Elm app", command);

      }
  });

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

      fileDownloading(hash);
      let data = await ipfsGet(multiaddr, hash);
      fileLog(hash, "File downloaded from " + multiaddr);

      let preview = getPreview(data);

      fileLoaded(hash, preview);
      knownFiles[hash] = {
        bytes: data,
        multiaddr,
        preview
      };
    }

  });

  // TODO resize images
  function getPreview(data) {

    // if data is more than 10Mb, do not show preview, it will be laggy
    if (data.length > 10 * 1000 * 1000) return null;

    let imageType = getImageType(data);

    let preview = null;
    if (imageType) {
      let base64 = Buffer.from(data).toString('base64');
      preview = "data:image/" + imageType + ";base64," + base64;
    }

    return preview;
  }
}