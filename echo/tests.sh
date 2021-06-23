#!/usr/bin/env bash

set -euo pipefail

function message {
    echo ""
    echo "---------------------------------------------------------------"
    echo $1
    echo "---------------------------------------------------------------"
}

RESTORE=$(echo -en '\033[0m')
RED=$(echo -en '\033[01;31m')
GREEN=$(echo -en '\033[01;32m')

function failed {
    echo ${RED}✗$1${RESTORE}
}

function passed {
    echo ${GREEN}✓$1${RESTORE}
}

if ! [ -x "$(command -v jq)" ]; then
    message "JQ not installed. Installing..."
    sudo apt -y install jq
fi


message " Build image "
docker build -t mendhak/http-https-echo:latest .

mkdir -p testarea
pushd testarea

message " Cleaning up from previous test run "
docker ps -q --filter "name=http-echo-tests" | grep -q . && docker stop http-echo-tests

message " Start container normally "
docker run -d --rm --name http-echo-tests -p 8080:8080 -p 8443:8443 -t mendhak/http-https-echo
sleep 5


message " Make http(s) request, and test the path, method, header and status code. "
REQUEST=$(curl -s -k -X PUT -H "Arbitrary:Header" -d aaa=bbb https://localhost:8443/hello-world)
if [ $(echo $REQUEST | jq -r '.path') == '/hello-world' ] && \
   [ $(echo $REQUEST | jq -r '.method') == 'PUT' ] && \
   [ $(echo $REQUEST | jq -r '.headers.arbitrary') == 'Header' ]
then
    passed "HTTPS request passed."
else
    failed "HTTPS request failed."
    echo $REQUEST | jq
    exit 1
fi
REQUEST_WITH_STATUS_CODE=$(curl -s -k -o /dev/null -w "%{http_code}" -H "x-set-response-status-code: 404" https://localhost:8443/hello-world)
REQUEST_WITH_STATUS_CODE_V=$(curl -v -k -o /dev/null -w "%{http_code}" -H "x-set-response-status-code: 404" https://localhost:8443/hello-world)
if [ $(echo $REQUEST_WITH_STATUS_CODE == '404') ]
then
    passed "HTTPS status code request passed."
else
    failed "HTTPS status code request failed."
    echo $REQUEST_WITH_STATUS_CODE_V
    exit 1
fi

REQUEST_WITH_SLEEP_MS=$(curl -o /dev/null -Ss -H "x-set-response-delay-ms: 6000" -k https://localhost:8443/ -w '%{time_total}')
if [[ $(echo "$REQUEST_WITH_SLEEP_MS>5" | bc -l) == 1 ]]; then 
    passed "Request with response delay passed"
else 
    failed "Request with response delay failed"
    echo $REQUEST_WITH_SLEEP_MS
    exit 1
fi

REQUEST_WITH_INVALID_SLEEP_MS=$(curl -o /dev/null -Ss -H "x-set-response-delay-ms: XXXX" -k https://localhost:8443/ -w '%{time_total}')
if [[ $(echo "$REQUEST_WITH_INVALID_SLEEP_MS<2" | bc -l) == 1 ]]; then 
    passed "Request with invalid response delay passed"
else 
    failed "Request with invalid response delay failed"
    echo $REQUEST_WITH_INVALID_SLEEP_MS
    exit 1
fi

REQUEST=$(curl -s -X PUT -H "Arbitrary:Header" -d aaa=bbb http://localhost:8080/hello-world)
if [ $(echo $REQUEST | jq -r '.path') == '/hello-world' ] && \
   [ $(echo $REQUEST | jq -r '.method') == 'PUT' ] && \
   [ $(echo $REQUEST | jq -r '.headers.arbitrary') == 'Header' ]
then
    passed "HTTP request with arbitrary header passed."
else
    failed "HTTP request with arbitrary header failed."
    echo $REQUEST | jq
    exit 1
fi

message " Make JSON request, and test that json is in the output. "
REQUEST=$(curl -s -X POST -H "Content-Type: application/json" -d '{"a":"b"}' http://localhost:8080/)
if [ $(echo $REQUEST | jq -r '.json.a') == 'b' ]
then
    passed "JSON test passed."
else
    failed "JSON test failed."
    echo $REQUEST | jq
    exit 1
fi

message " Stop containers "
docker stop http-echo-tests

message " Start container with different internal ports "
docker run -d --rm -e HTTP_PORT=8888 -e HTTPS_PORT=9999 --name http-echo-tests -p 8080:8888 -p 8443:9999 -t mendhak/http-https-echo
sleep 5

message " Make http(s) request, and test the path, method and header. "
REQUEST=$(curl -s -k -X PUT -H "Arbitrary:Header" -d aaa=bbb https://localhost:8443/hello-world)
if [ $(echo $REQUEST | jq -r '.path') == '/hello-world' ] && \
   [ $(echo $REQUEST | jq -r '.method') == 'PUT' ] && \
   [ $(echo $REQUEST | jq -r '.headers.arbitrary') == 'Header' ]
then
    passed "HTTPS request passed."
else
    failed "HTTPS request failed."
    echo $REQUEST | jq
    exit 1
fi

REQUEST=$(curl -s -X PUT -H "Arbitrary:Header" -d aaa=bbb http://localhost:8080/hello-world)
if [ $(echo $REQUEST | jq -r '.path') == '/hello-world' ] && \
   [ $(echo $REQUEST | jq -r '.method') == 'PUT' ] && \
   [ $(echo $REQUEST | jq -r '.headers.arbitrary') == 'Header' ]
then
    passed "HTTP request passed."
else
    failed "HTTP request failed."
    echo $REQUEST | jq
    exit 1
fi


message " Stop containers "
docker stop http-echo-tests


message " Start container with JWT_HEADER "
docker run -d --rm -e JWT_HEADER=Authentication --name http-echo-tests -p 8080:8080 -p 8443:8443 -t mendhak/http-https-echo
sleep 5

REQUEST=$(curl -s -k -H "Authentication: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c" https://localhost:8443/ )
if [ $(echo $REQUEST | jq -r '.jwt.header.typ') == 'JWT' ] && \
   [ $(echo $REQUEST | jq -r '.jwt.header.alg') == 'HS256' ] && \
   [ $(echo $REQUEST | jq -r '.jwt.payload.sub') == '1234567890' ]
then
    passed "JWT request passed."
else
    failed "JWT request failed."
    echo $REQUEST | jq
    exit 1
fi

message " Stop containers "
docker stop http-echo-tests


message " Start container with LOG_IGNORE_PATH "
docker run -d --rm -e LOG_IGNORE_PATH=/ping --name http-echo-tests -p 8080:8080 -p 8443:8443 -t mendhak/http-https-echo
sleep 5
curl -s -k -X POST -d "banana" https://localhost:8443/ping > /dev/null

if [ $(docker logs http-echo-tests | wc -l) == 1 ] && \
   ! [ $(docker logs http-echo-tests | grep banana) ]
then
    passed "LOG_IGNORE_PATH ignored the /ping path"
else
    failed "LOG_IGNORE_PATH failed"
    docker logs http-echo-tests
    exit 1
fi


message " Stop containers "
docker stop http-echo-tests

message " Start container with LOG_WITHOUT_NEWLINE "
docker run -d --rm -e LOG_WITHOUT_NEWLINE=1 --name http-echo-tests -p 8080:8080 -p 8443:8443 -t mendhak/http-https-echo
sleep 5
curl -s -k -X POST -d "tiramisu" https://localhost:8443/ > /dev/null

if [ $(docker logs http-echo-tests | wc -l) == 3 ] && \
   [ $(docker logs http-echo-tests | grep tiramisu) ]
then
    passed "LOG_WITHOUT_NEWLINE logged output in single line"
else
    failed "LOG_WITHOUT_NEWLINE failed"
    docker logs http-echo-tests
    exit 1
fi


message " Stop containers "
docker stop http-echo-tests

message " Check that container is running as a NON ROOT USER by default"
docker run -d --name http-echo-tests --rm mendhak/http-https-echo

WHOAMI=$(docker exec http-echo-tests whoami)

if [ "$WHOAMI" == "node" ]
then
    passed "Running as non root user"
else
    failed "Running as root user"
    exit 1
fi

message " Stop containers "
docker stop http-echo-tests

message " Check that container is running as user different that the user defined in image"
IMAGE_USER="$(docker image inspect mendhak/http-https-echo -f '{{ .ContainerConfig.User }}')"
CONTAINER_USER="$((IMAGE_USER + 1000000))"
docker run -d --name http-echo-tests --rm -u "${CONTAINER_USER}" -p 8080:8080 mendhak/http-https-echo
sleep 5
curl -s http://localhost:8080 > /dev/null

WHOAMI="$(docker exec http-echo-tests id -u)"

if [ "$WHOAMI" == "$CONTAINER_USER" ]
then
    passed "Running as $CONTAINER_USER user"
else
    failed "Not running as $CONTAINER_USER user or failed to start"
    exit 1
fi

message " Stop containers "
docker stop http-echo-tests

popd
rm -rf testarea
