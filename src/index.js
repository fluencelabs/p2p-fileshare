import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';
import "regenerator-runtime";
import Hash from 'ipfs-only-hash';
import {JanusClient} from 'janus-beta';


var app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: null
});

app.ports.calcHash.subscribe(async (fileBytesArray) => {
  var h = await Hash.of(fileBytesArray)

  app.ports.hashReceiver.send(h);
})


// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
