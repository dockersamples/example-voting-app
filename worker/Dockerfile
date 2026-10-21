# because of dotnet, we always build on amd64, and target platforms in cli
# dotnet doesn't support QEMU for building or running.
# hadolint ignore=DL3029
FROM --platform=${BUILDPLATFORM} mcr.microsoft.com/dotnet/sdk:10.0@sha256:0d99ebf1ccad15037b5c98c9fe8979d6b8dbac23812feae2277a0b277b5c5ffa AS build
ARG TARGETPLATFORM
ARG TARGETARCH
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"

WORKDIR /source
COPY *.csproj .
RUN dotnet restore -a $TARGETARCH

COPY . .
RUN dotnet publish -c release -o /app -a $TARGETARCH --self-contained false --no-restore

# app image
FROM mcr.microsoft.com/dotnet/runtime:10.0@sha256:939555726cae4c916d212323ac3c0792996dcac2614f00e82cc40fcf059e1af3
WORKDIR /app
COPY --from=build /app .
# .NET 8+ images ship a non-root "app" user; APP_UID is set by the base image
USER $APP_UID
ENTRYPOINT ["dotnet", "Worker.dll"]
