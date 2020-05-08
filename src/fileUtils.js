import IpfsClient from "ipfs-http-client";

// Get a file from a node with $multiaddr address
export async function ipfsGet(multiaddr, path) {
    const ipfs = new IpfsClient(multiaddr);
    const source = ipfs.cat(path);
    let chunks = [];
    try {
        for await (const chunk of source) {
            chunks.push(Buffer.from(chunk));
        }
        return Promise.resolve(Buffer.concat(chunks));
    } catch (err) {
        console.error(err);
    }
}

// Add a file to IPFS node with $multiaddr address
export async function ipfsAdd(multiaddr, file) {
    const ipfs = new IpfsClient(multiaddr);
    const source = ipfs.add([file]);
    try {
        for await (const file of source) {
            console.log(`file uploaded to '${multiaddr}'`);
        }
    } catch (err) {
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
    setTimeout(function () {
        return window.URL.revokeObjectURL(url);
    }, 1000);
}

export function getImageType(data) {
    if (data[0] === 0xFF && data[1] === 0xD8 && data[2] === 0xFF) {
        return "jpeg"
    } else if (data[0] === 0x89 &&
        data[1] === 0x50 &&
        data[2] === 0x4E &&
        data[3] === 0x47 &&
        data[4] === 0x0D &&
        data[5] === 0x0A &&
        data[6] === 0x1A &&
        data[7] === 0x0A) {
        return "png"
    } else if (data[0] === 0x47 && data[1] === 0x49 && data[2] === 0x46) {
        return "gif"
    }

    return null;
}