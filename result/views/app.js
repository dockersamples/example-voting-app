
var app = angular.module('catsvsdogs', []);
var socket = io.connect();

var bg1 = document.getElementById('background-stats-1');
var bg2 = document.getElementById('background-stats-2');
var bg3 = document.getElementById('background-stats-3');

app.controller('statsCtrl', function ($scope) {
  $scope.aPercent = 33.3;
  $scope.bPercent = 33.3;
  $scope.cPercent = 33.4;
  $scope.total = 0;

  var updateScores = function () {
    socket.on('scores', function (json) {
      var data = JSON.parse(json);

      var a = parseInt(data.a || 0, 10);
      var b = parseInt(data.b || 0, 10);
      var c = parseInt(data.c || 0, 10);

      var percentages = getPercentages(a, b, c);

      bg1.style.width = percentages.a + '%';
      bg2.style.width = percentages.b + '%';
      bg3.style.width = percentages.c + '%';

      $scope.$apply(function () {
        $scope.aPercent = percentages.a;
        $scope.bPercent = percentages.b;
        $scope.cPercent = percentages.c;
        $scope.total = a + b + c;
      });
    });
  };

  var init = function () {
    document.body.style.opacity = 1;
    updateScores();
  };

  socket.on('message', function () {
    init();
  });
});

function getPercentages(a, b, c) {
  var result = {};
  var total = a + b + c;

  if (total > 0) {
    result.a = Math.round((a / total) * 1000) / 10;
    result.b = Math.round((b / total) * 1000) / 10;
    result.c = Math.round((100 - result.a - result.b) * 10) / 10;
  } else {
    result.a = 33.3;
    result.b = 33.3;
    result.c = 33.4;
  }

  return result;
}
