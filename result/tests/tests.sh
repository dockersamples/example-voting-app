#!/bin/sh
while ! timeout 1 bash -c "echo > /dev/tcp/vote/80"; do sleep 1; done
curl -sS -X POST --data "vote=a" http://vote > /dev/null
curl -sS -X POST --data "vote=b" http://vote > /dev/null
sleep 10
if phantomjs render.js http://result | grep -q '2 votes'; then
  echo -e "\e[42m------------"
  echo -e "\e[92mTests passed"
  echo -e "\e[42m------------"
  exit 0
fi
  echo -e "\e[41m------------"
  echo -e "\e[91mTests failed"
  echo -e "\e[41m------------"
  exit 1
