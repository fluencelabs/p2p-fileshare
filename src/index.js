import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';
import "regenerator-runtime";
import 'ipfs-only-hash';

Elm.Main.init({
  node: document.getElementById('root'),
  flags: null
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
