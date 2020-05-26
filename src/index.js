import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

import ports from './ports';

let path = window.location.pathname;

let flags;
if (path === "/admin") {
  flags = { isAdmin: true, peerId: null }
} else {
  flags = null
}

let app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: flags
});

(async () => {
  await ports(app).catch((e) => {
    console.error(e)
  });
})();

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
