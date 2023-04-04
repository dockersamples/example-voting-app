# IMPORTANT

because of dotnet, we always build on amd64, and target platforms in cli dotnet doesn't support QEMU for building or running. 

(errors common in arm/v7 32bit) https://github.com/dotnet/dotnet-docker/issues/1537
https://hub.docker.com/_/microsoft-dotnet
hadolint ignore=DL3029


to build for a different platform than your host, use --platform=<platform>

for example, if you were on Intel (amd64) and wanted to build for ARM, you would use:

docker buildx build --platform "linux/arm64/v8" .


# For Linux

docker buildx build --platform "linux/amd64" .


## docker buildx install on Linux
If you have Jenkins server to build the docker image, you need to install
docker buildx on it. The following provides the details:
https://docs.docker.com/build/install-buildx/

