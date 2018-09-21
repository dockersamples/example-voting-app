"use strict";

var connection = new signalR.HubConnectionBuilder().withUrl("/resultsHub").build();

connection.on("UpdateResults", function (results) {
    data = JSON.parse(json);

    var a = parseInt(data.optionA || 0);
    var b = parseInt(data.optionB || 0);
    var percentages = getPercentages(a, b);

    document.getElementById("optionA").innerText = percentages.a + "%";
    document.getElementById("optionB").innerText = percentages.b + "%";
});

connection.start().catch(function (err) {
    return console.error(err.toString());
});

function getPercentages(a, b) {
    var result = {};

    if (a + b > 0) {
        result.a = Math.round(a / (a + b) * 100);
        result.b = 100 - result.a;
    } else {
        result.a = result.b = 50;
    }

    return result;
}