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

// import './main.css';
import {Elm} from './Main.elm';
import * as serviceWorker from './serviceWorker';
import ports, {getRelays} from "./ports";
import {convertRelayForELM} from "./utils";
import {createBlog, joinBlog, publishBlueprint} from "./globalFunctions";
import {BLOG_ID, relays} from "./main";

let isAdmin: boolean = false;
if (window.location.pathname === "/admin") {
    isAdmin = true;
}

let flags: any = {
    peerId: null,
    admin: isAdmin,
    defaultPeerRelayInput: {
        host: "134.209.186.43",
        pport: "9001",
        peerId: "12D3KooWEXNUbCXooUwHrHBbrmjsrpHXoEphPwbjQXEGyzbqKnE9",
        privateKey: ""
    },
    relays: getRelays().map(convertRelayForELM),
    windowSize: {
        width: window.innerWidth,
        height: window.innerHeight,
    }
};

let app = Elm.Main.init({
    node: document.getElementById('root'),
    flags: flags
});

(async () => {
    await ports(app).catch((e: any) => {
        console.error(e)
    });

    if (isAdmin) {
        let blogId = ""
        let seed = ""
        await joinBlog("", BLOG_ID, seed)
    }
})();

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();

declare global {
    interface Window {
        createBlog: any;
        relays: any;
        publishBlueprint: any;
    }
}

window.createBlog = createBlog;
window.relays = relays;
window.publishBlueprint = publishBlueprint;
