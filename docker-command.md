# Build and Run Voting App using Docker

- [Build and Run Voting App using Docker](#build-and-run-voting-app-using-docker)
    - [Git Clone](#git-clone)
    - [Docker Build](#docker-build)
    - [Docker Network](#docker-network)
    - [Docker Run](#docker-run)

## Git Clone
```sh
git clone <github url: example-voting-app> 
```

## Docker Build
| Image        | Command                        |
| ------------ | ------------------------------ |
| vote         | docker build -t vote vote/     |
| result       | docker build -t result result/ |
| woker        | docker build -t worker worker/ |
| postgres:9.4 | docker pull postgres:9.4       |
| redis:alpine | docker pull redis:alpine       |

## Docker Network
Create a Bridge 
```sh
docker network create --subnet 192.168.0.0/24 my-network
```

## Docker Run
Running Containers

| Container | Command                                                                          |
| --------- | -------------------------------------------------------------------------------- |
| vote      | docker run -d -p 8080:80 --network my-network --name vote vote                   |
| result    | docker run -d -p 8081:80 -p 5858:5858 --network my-network  --name result result |
| redis     | docker run -d --network my-network --name redis redis:alpine                     |
| db        | docker run -d --network my-network --name db postgres:9.4                        |
| worker    | docker run -d --network my-network --name worker worker                          |

