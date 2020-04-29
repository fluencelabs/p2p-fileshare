import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';
import "regenerator-runtime";
import Hash from 'ipfs-only-hash';
import {JanusClient, genUUID, makeFunctionCall} from 'janus-beta';

async function calculateSum() {

  let errorHandler = (error) => {
    console.log("error: " + error)
  };

  // connect to two different nodes
  let con1 = await JanusClient.connect(errorHandler, "QmVL33cyaaGLWHkw5ZwC7WFiq1QATHrBsuJeZ2Zky7nDpz", "104.248.25.59", 9001);
  // let con2 = await JanusClient.connect(errorHandler, "QmVzDnaPYN12QAYLDbGzvMgso7gbRD9FQqRvGZBfeKDSqW", "104.248.25.59", 9002);
  //
  // // service name that we will register with one connection and call with another
  // let serviceName = "sum-calculator";
  //
  // // register service that will add two numbers and send a response with calculation result
  // await con1.registerService(serviceName, async (req) => {
  //   console.log("message received");
  //   console.log(req);
  //
  //   console.log("send response");
  //
  //   let response = makeFunctionCall(genUUID(), req.reply_to, {msgId: req.arguments.msgId, result: req.arguments.one + req.arguments.two});
  //   console.log(response);
  //
  //   await con1.sendFunctionCall(response);
  // });
  //
  //
  // // msgId is to identify response
  // let msgId = "calculate-it-for-me";
  //
  // let req = {one: 12, two: 23, msgId: msgId};
  //
  // // send call to `sum-calculator` service with two numbers
  // await con2.sendServiceCall(serviceName, req, "calculator request");
  //
  // let resultPromise = new Promise((resolve, reject) => {
  //   // subscribe for responses, to handle response
  //   con2.subscribe((call) => {
  //     if (call.arguments.msgId && call.arguments.msgId === msgId) {
  //       console.log("response received!");
  //
  //       resolve(call.arguments.result);
  //       return true;
  //     }
  //     return false;
  //   });
  // });
  //
  // let result = await resultPromise;
  // console.log(`calculation result is: ${result}`);
}

 // (async () => {
 //   await calculateSum();
 // })();

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
