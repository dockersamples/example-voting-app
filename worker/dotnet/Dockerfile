FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim as builder

WORKDIR /Worker
COPY Worker/Worker.csproj .
RUN dotnet restore

COPY /Worker .
RUN dotnet publish -c Release -o /out Worker.csproj

# app image
FROM mcr.microsoft.com/dotnet/runtime:6.0-bullseye-slim

WORKDIR /app
ENTRYPOINT ["dotnet", "Worker.dll"]

COPY --from=builder /out .