"use strict";

var connection = new signalR.HubConnectionBuilder().withUrl("/resultsHub").build();

connection.on("UpdateResults", function (results) {
    document.body.style.opacity=1;

    var a = parseInt(results.optionA || 0);
    var b = parseInt(results.optionB || 0);
    var percentages = getPercentages(a, b);

    document.getElementById("optionA").innerText = percentages.a + "%";
    document.getElementById("optionB").innerText = percentages.b + "%";
    var totalVotes = 'No votes yet';
    if (results.voteCount > 0) {
        totalVotes = results.voteCount + (results.voteCount > 1 ? " votes" : " vote");        
    }
    document.getElementById("totalVotes").innerText = totalVotes;

    var bg1 = document.getElementById('background-stats-1');
    var bg2 = document.getElementById('background-stats-2');
    bg1.style.width = (percentages.a-0.2) + "%";
    bg2.style.width = (percentages.b-0.2) + "%";
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