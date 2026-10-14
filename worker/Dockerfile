FROM --platform=${BUILDPLATFORM} mcr.microsoft.com/dotnet/sdk:10.0 AS build

ARG TARGETARCH
WORKDIR /source

COPY Worker.csproj .
RUN dotnet restore -a $TARGETARCH

COPY . .
RUN dotnet publish Worker.csproj -c Release -o /app -a $TARGETARCH --self-contained false --no-restore

FROM mcr.microsoft.com/dotnet/runtime:10.0

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends libgssapi-krb5-2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app .

USER $APP_UID

ENTRYPOINT ["dotnet", "Worker.dll"]
