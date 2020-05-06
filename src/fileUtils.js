import IpfsClient from "ipfs-http-client";


import isPng from "is-png";
import isGif from "is-gif";
import isJpg from "is-jpg";

// Get a file from a node with $multiaddr address
export async function ipfsGet(multiaddr, path) {
  const ipfs = new IpfsClient(multiaddr);
  const source = ipfs.cat(path);
  let bytes = new Uint8Array();
  try {
    for await (const chunk of source) {
      const newArray = new Uint8Array(bytes.length + chunk.length);
      newArray.set(bytes, 0);
      newArray.set(chunk, bytes.length);
      bytes = newArray;
    }
  }
  catch (err) {
    console.error(err);
  }
  return Promise.resolve(bytes);
}

// Add a file to IPFS node with $multiaddr address
export async function ipfsAdd(multiaddr, file) {
  const ipfs = new IpfsClient(multiaddr);
  const source = ipfs.add([file]);
  try {
    for await (const file of source) {
      console.log(`file uploaded to '${multiaddr}'`);
    }
  }
  catch (err) {
    console.error(err);
  }
  return Promise.resolve();
}


export function downloadBlob(data, fileName, mimeType) {
  let blob, url;
  blob = new Blob([data], {
    type: mimeType
  });
  url = window.URL.createObjectURL(blob);

  let downloadURL = (data, fileName) => {
    let a;
    a = document.createElement('a');
    a.href = data;
    a.download = fileName;
    document.body.appendChild(a);
    a.style = 'display: none';
    a.click();
    a.remove();
  };

  downloadURL(url, fileName);
  setTimeout(function() {
    return window.URL.revokeObjectURL(url);
  }, 1000);
}

// TODO delete and remove from dependencies
export function imageType(data) {
  return isPng(data) ? "png" : (isGif(data) ? "gif" : (isJpg(data) ? "jpg" : null));
}