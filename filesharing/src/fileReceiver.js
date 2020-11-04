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

import {getApp} from "./ports";

let emptyFileEvent = {hash: null, log: null, preview: null};

/**
 * Handle file commands, sending events
 */
export function sendToFileReceiver(ev) {
    getApp().ports.fileReceiver.send({...emptyFileEvent, ...ev});
}

export function fileAdvertised(hash, preview) {
    sendToFileReceiver({event: "advertised", hash, preview});
}
export function fileUploading(hash) {
    sendToFileReceiver({event: "uploading", hash});
}
export function fileUploaded(hash) {
    sendToFileReceiver({event: "uploaded", hash});
}
export function fileDownloading(hash) {
    sendToFileReceiver({event: "downloading", hash});
}
export function fileAsked(hash) {
    sendToFileReceiver({event: "asked", hash});
}
export function fileRequested(hash) {
    sendToFileReceiver({event: "requested", hash});
}
export function fileLoaded(hash, preview) {
    sendToFileReceiver({event: "loaded", hash, preview});
}
export function hashCopied(hash) {
    sendToFileReceiver({event: "copied", hash});
}
export function fileLog(hash, log) {
    sendToFileReceiver({event: "log", hash, log});
}
export function resetEntries() {
    sendToFileReceiver({event: "reset_entries"});
}