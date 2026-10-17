
var app = angular.module('catsvsdogs', []);
var socket = io.connect();

app.controller('statsCtrl', function ($scope) {
  $scope.aPercent = 0;
  $scope.bPercent = 0;
  $scope.cPercent = 0;
  $scope.total = 0;

  // Reveal the page
  document.body.style.opacity = 1;

  // Listen for score updates continuously
  socket.on('scores', function (json) {
    var data;

    try {
      data = typeof json === 'string'
        ? JSON.parse(json)
        : json;
    } catch (error) {
      console.error('Invalid scores data:', error);
      return;
    }

    if (!data) return;

    var a = Math.max(0, Number(data.a) || 0);
    var b = Math.max(0, Number(data.b) || 0);
    var c = Math.max(0, Number(data.c) || 0);

    var total = a + b + c;

    var percentages = getPercentages(a, b, c);

    // Update AngularJS safely
    $scope.$applyAsync(function () {
      $scope.aPercent = percentages.a;
      $scope.bPercent = percentages.b;
      $scope.cPercent = percentages.c;
      $scope.total = total;
    });
  });

  // Support the existing page initialization event
  socket.on('message', function () {
    document.body.style.opacity = 1;
  });
});

function getPercentages(a, b, c) {
  var total = a + b + c;

  if (total === 0) {
    return {
      a: 0,
      b: 0,
      c: 0
    };
  }

  var aPercent = Math.round((a / total) * 1000) / 10;
  var bPercent = Math.round((b / total) * 1000) / 10;

  // Make the displayed percentages total exactly 100%
  var cPercent = Math.round(
    (100 - aPercent - bPercent) * 10
  ) / 10;

  return {
    a: aPercent,
    b: bPercent,
    c: cPercent
  };
}
