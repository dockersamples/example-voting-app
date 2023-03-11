# because of dotnet, we always build on amd64, and target platforms in cli
# dotnet doesn't support QEMU for building or running. 
# (errors common in arm/v7 32bit) https://github.com/dotnet/dotnet-docker/issues/1537
# https://hub.docker.com/_/microsoft-dotnet
# hadolint ignore=DL3029
FROM mcr.microsoft.com/dotnet/sdk:7.0 as build

WORKDIR /source
COPY *.csproj .
RUN dotnet restore -r linux-x64

COPY . .
RUN dotnet publish -c release -o /app -r linux-x64 --self-contained false --no-restore

# app image
FROM mcr.microsoft.com/dotnet/runtime:7.0
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "Worker.dll"]