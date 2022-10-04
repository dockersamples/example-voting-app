FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim as builder

WORKDIR /Worker
COPY src/Worker/Worker.csproj .
RUN dotnet restore

COPY src/Worker/ .
RUN dotnet publish -c Release -o /out Worker.csproj

# app image
FROM mcr.microsoft.com/dotnet/runtime:6.0-bullseye-slim

WORKDIR /app
ENTRYPOINT ["dotnet", "Worker.dll"]

COPY --from=builder /out .