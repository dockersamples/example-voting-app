#!/bin/sh

echo "I: Checking if frontend vote app is available..."

curl  http://vote > /dev/null 2>&1

if [ $? -eq 0 ]
then
  echo "---------------------------------------"
  echo "Vote app is available....proceeding"
  echo "---------------------------------------"
else
  echo "---------------------------------------"
  echo "Vote app is not avilable....aborting"
  echo "---------------------------------------"
  exit 2
fi


echo "I: Launching integration test..."

# submit a vote. Will return an error if it fails to submit or store vote in redis
# Fail integration test if  it returns exit code 0 (error state)

curl -sS -X POST --data "vote=b" http://vote | grep -i erro

if [ $? -eq 0 ]
then
  # error, failed
  echo "-----------------------------"
  echo "INTEGRATION TEST FAILED"
  echo "-----------------------------"
  exit 1
else
  # passed
  echo "-----------------------------"
  echo "INTEGRATION TEST PASSED"
  echo "-----------------------------"
  exit 0
fi


