#!/bin/bash 

cd e2e 

docker-compose down > /dev/null 2>&1 

#sleep 10

docker-compose build
docker-compose up -d 

docker-compose ps

docker-compose run --rm e2e

docker-compose down 

