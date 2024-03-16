const stompClient = new StompJs.Client({
});

const jsConfetti = new JSConfetti()
var currentWorkflowId;
var currentIntervalId;


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

function winnerIsInTheAudience(){
  console.log("The Winner is in the audience!!");
  const response = fetch("/yes-winner-in-audience?workflowId="+currentWorkflowId, {
    method: "POST",
    headers: {
      "Content-type": "application/json; charset=UTF-8"
    }
  })
  document.getElementById("winnerIsInTheAudience").innerHTML = "<h2>The Winner is in the Audience 🥳👍 <h2>";
  document.getElementById("winnerGotTheBook").innerHTML = "<h2>Did the Winner got the Book?<h2>";
  
}

function getWorkflowStatus(workflowId){
  const fetchPromise =  fetch("/status?workflowId="+currentWorkflowId, {
    method: "GET",
    headers: {
      "Content-type": "application/json; charset=UTF-8"
    }
  });
  fetchPromise.then(response => response.json())
      .then(data => {
        console.log("Winner: " + data.winner);
        winner();
        document.getElementById("winner").innerHTML = "<h1> Winner: <b>" + data.winner + "</b><h1>";
        document.getElementById("winnerIsInTheAudience").innerHTML = "<h2>Is the Winner In the Audience??<h2>";
        document.getElementById("winnerGotTheBook").innerHTML = "";
  });
}

function winnerGotTheBook(){
  console.log("The Winner got the Book!!");
  const response = fetch("/yes-winner-got-book?workflowId="+currentWorkflowId, {
    method: "POST",
    headers: {
      "Content-type": "application/json; charset=UTF-8"
    }
  })
  document.getElementById("winnerGotTheBook").innerHTML = "<h2>The Winner got the Book! Congrats! 📚<h2>";
}

function waitForWinner(){
  const currentIntervalId = setInterval(() => { 
    
    getWorkflowStatus(currentWorkflowId); 
    console.log("fetching winner for workflow Id = "+ currentWorkflowId);
    if(document.getElementById("winner").innerHTML != ""){
         console.log("we got a winner!");
         clearInterval(currentIntervalId);
    }
  }, 4000);
  
}


function clean(){
  document.getElementById("winner").innerHTML = "";
  document.getElementById("winnerIsInTheAudience").innerHTML = "";
  document.getElementById("winnerGotTheBook").innerHTML = "";
}
function pickADogWinner(){
  clean();
  console.log("Let's pick a DOG winner!");
  const fetchPromise =  fetch("/pick-a-winner?option=a", {
    method: "POST",
    headers: {
      "Content-type": "application/json; charset=UTF-8"
    }
  });
  drumRoll();
  fetchPromise.then(response => response.text())
      .then(data => {
        console.log("Workflow Id: " + data);
        currentWorkflowId = data;
        waitForWinner();
  });
}

function pickACatWinner(){
  clean();
  console.log("Let's pick a CAT winner!");
  const fetchPromise = fetch("/pick-a-winner?option=b", {
    method: "POST",
    headers: {
      "Content-type": "application/json; charset=UTF-8"
    }
  })
  drumRoll();
  fetchPromise.then(response => response.text())
      .then(data => {
        console.log("Workflow Id: " + data);
        currentWorkflowId = data;
        waitForWinner();
  });
}

function cats(){
  jsConfetti.addConfetti({
    emojis: ['😺'],
    emojiSize: 100,
    confettiNumber: 6,
  })
}

function winner(){
  jsConfetti.addConfetti({
    emojis: ['🥳'],
    emojiSize: 200,
    confettiNumber: 50,
  })
}

function drumRoll(){
  jsConfetti.addConfetti({
    emojis: ['🥁'],
    emojiSize: 200,
    confettiNumber: 100,
  })
}

function dogs(){
  jsConfetti.addConfetti({
    emojis: ['🐶'],
    emojiSize: 100,
    confettiNumber: 6,
  })
}

function showEvent(event) {
  console.log("Option Selected: " + event.data.node.option)
  if (event.data.node.option == "a") {
    cats();
  }
  if (event.data.node.option == "b") {
    dogs();
  }

}




stompClient.onWebSocketError = (error) => {
  console.error('Error with websocket', error);
};

stompClient.onStompError = (frame) => {
  console.error('Broker reported error: ' + frame.headers['message']);
  console.error('Additional details: ' + frame.body);
};


