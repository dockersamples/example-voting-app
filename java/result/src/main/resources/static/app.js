var app = angular.module("catsvsdogs", []);
console.log("Location Host: " + location.host);


var bg1 = document.getElementById("background-stats-1");
var bg2 = document.getElementById("background-stats-2");

app.controller("statsCtrl", function ($scope) {
  const stompClient = new StompJs.Client({
    brokerURL: 'ws://'+location.host+'/websocket'
  });
  
  connect();
  
  stompClient.onConnect = (frame) => {
    console.log('Connected: ' + frame);
    init();

    stompClient.subscribe('/topic/scores', (scores) => {
      
      //showGreeting(JSON.parse(greeting.body).content);
      console.log("JSON update scores: " + scores.body);
      data = JSON.parse(scores.body);
      console.log("Getting scores" + data);
      var a = parseInt(data.a || 0);
      var b = parseInt(data.b || 0);

      var percentages = getPercentages(a, b);

      bg1.style.width = percentages.a + "%";
      bg2.style.width = percentages.b + "%";

      $scope.$apply(function () {
        $scope.aPercent = percentages.a;
        $scope.bPercent = percentages.b;
        $scope.total = a + b;
      });
  });
    
  };
  
  stompClient.onWebSocketError = (error) => {
    console.error('Error with websocket', error);
  };
  
  stompClient.onStompError = (frame) => {
    console.error('Broker reported error: ' + frame.headers['message']);
    console.error('Additional details: ' + frame.body);
  };
  
  
  
  function connect() {
    stompClient.activate();
  }
  
  function disconnect() {
    stompClient.deactivate();
  }

  $scope.aPercent = 50;
  $scope.bPercent = 50;


  var init = function () {
    document.body.style.opacity = 1;
  };

  
  
  
});

function getPercentages(a, b) {
  var result = {};

  if (a + b > 0) {
    result.a = Math.round((a / (a + b)) * 100);
    result.b = 100 - result.a;
  } else {
    result.a = result.b = 50;
  }

  return result;
}
