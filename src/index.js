import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

import ports from './ports';

var app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: null
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
