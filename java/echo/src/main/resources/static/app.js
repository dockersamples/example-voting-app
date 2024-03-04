const stompClient = new StompJs.Client({
});

const jsConfetti = new JSConfetti()

function connect() {

  console.log("Fetching Server Info")
  fetch("/server-info", {
    method: "GET",
    headers: {
      "Content-type": "application/json; charset=UTF-8"
    }
  }).then((response) => {
    console.log("Fetching Response")
    return response.json();
  }).then((response) => {
    var websocketProtocol = location.protocol === "https:" ? "wss:" : "ws:";
    var publicURL = websocketProtocol + '//' + response.publicIp + '/ws';
    stompClient.brokerURL = publicURL;
    console.log(publicURL);
    console.log("Activating client")
    stompClient.activate();
  }).catch((error) => {
    console.error(`Could not get server-info: ${error}`);
  });
};

stompClient.onConnect = (frame) => {

  console.log('Connected: ' + frame);
  stompClient.subscribe('/topic/events', (event) => {
    console.log(JSON.parse(event.body));
    showEvent(JSON.parse(event.body));

  });
};

function showEvent(event) {
  console.log("Option Selected: " + event.data.node.option)
  if (event.data.node.option == "a") {
    jsConfetti.addConfetti({
      emojis: ['😺'],
      emojiSize: 100,
      confettiNumber: 30,
    })
  }
  if (event.data.node.option == "b") {
    jsConfetti.addConfetti({
      emojis: ['🐶'],
      emojiSize: 100,
      confettiNumber: 30,
    })
  }

}




stompClient.onWebSocketError = (error) => {
  console.error('Error with websocket', error);
};

stompClient.onStompError = (frame) => {
  console.error('Broker reported error: ' + frame.headers['message']);
  console.error('Additional details: ' + frame.body);
};


