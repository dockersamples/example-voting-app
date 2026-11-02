#!/bin/sh
set -eu

# Wait until the voting service is reachable
while ! timeout 1 bash -c "echo > /dev/tcp/vote/80"; do
    sleep 1
done

# Read the rendered vote count before submitting a vote
before=$(phantomjs render.js http://result | grep -oE '[0-9]+ votes?' | head -n 1 | grep -oE '^[0-9]+' || echo 0)

# Submit one vote
curl -fsS -X POST --data "vote=b" http://vote > /dev/null

# Allow time for the vote to be processed
sleep 10

# Read the rendered vote count again
after=$(phantomjs render.js http://result | grep -oE '[0-9]+ votes?' | head -n 1 | grep -oE '^[0-9]+' || echo 0)

# Confirm that the vote count increased
if [ "$after" -gt "$before" ]; then
    echo "Tests passed: vote count increased from $before to $after."
    exit 0
else
    echo "Tests failed: vote count did not increase. Before: $before; after: $after."
    exit 1
fi
