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

import "regenerator-runtime";

import Fluence from 'fluence';
import {initAdmin} from "./admin"

let conn;
let app;

export function getApp() {
    return app
}

export function setApp(newApp) {
    app = newApp
}

export function setConnection(app, connection) {
    conn = connection;
}

export function getConnection() {
    return conn
}

export default async function ports(app) {
    setApp(app)

    let peerId = await Fluence.generatePeerId();
    let conn = Fluence.connect("/ip4/127.0.0.1/tcp/9001/ws/p2p/12D3KooWQ8x4SMBmSSUrMzY2m13uzC7UoSyvHaDhTKx7hH8aXxpt", peerId)
    setConnection(app, conn);

    await initAdmin(app);
}