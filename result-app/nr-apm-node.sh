#!/bin/bash

echo "Installing New Relic"

# node.js -- result-app
# add newrelic to package.json -- "newrelic": "^1.26.1" -- (https://www.npmjs.com/~newrelic)

# set app name in newrelic.js
echo "Setting app name in newrelic.js"
sed -i -r "s/My Application/result-app/" /node_modules/newrelic/newrelic.js

# set monitoring aggression from "info" to "trace" (trace is more meticulous, requires more overhead)
# sed -i -r "s/info/trace/" node_modules/newrelic/newrelic.js

# add license key to newrelic.js
echo "Adding license key to newrelic.js"
sed -i -r "s/license key here/*****LICENSE_KEY_HERE*****/" /node_modules/newrelic/newrelic.js

# inject newrelic require statement in server.js
echo "Adding require('newrelic') statement to server.js"
sed -i "1ivar newrelic = require('newrelic');" server.js