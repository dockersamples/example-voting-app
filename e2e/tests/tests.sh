#!/bin/bash

current=""
next=""

while ! timeout 1 bash -c "echo > /dev/tcp/vote/80"; do
    sleep 1
done

# add initial vote 
curl -sS -X POST --data "vote=a" http://vote > /dev/null

current=`phantomjs render.js "http://result:4000/" | grep -i vote | cut -d ">" -f 4 | cut -d " " -f1`
next=`echo "$(($current + 1))"`

  echo -e "\n\n-----------------"
  echo -e "Current Votes Count: $current"
  echo -e "-----------------\n"

echo -e " I: Submitting one more vote...\n"

curl -sS -X POST --data "vote=b" http://vote > /dev/null
sleep 3

new=`phantomjs render.js "http://result:4000/" | grep -i vote | cut -d ">" -f 4 | cut -d " " -f1`


  echo -e "\n\n-----------------"
  echo -e "New Votes Count: $new"
  echo -e "-----------------\n"

echo -e "I: Checking if votes tally......\n"

if [ "$next" -eq "$new" ]; then
  echo -e "\\e[42m------------"
  echo -e "\\e[92mTests passed"
  echo -e "\\e[42m------------"
  exit 0
else
  echo -e "\\e[41m------------"
  echo -e "\\e[91mTests failed"
  echo -e "\\e[41m------------"
  exit 1
fi
