# Build Image
FROM mcr.microsoft.com/dotnet/sdk:7.0 as build
ARG TARGETPLATFORM
ARG TARGETARCH
RUN echo "I am building for $TARGETPLATFORM"

WORKDIR /source
COPY *.csproj .
RUN dotnet restore -a $TARGETARCH

COPY . .
RUN dotnet publish -c release -o /app -a $TARGETARCH --self-contained false --no-restore

# app image
FROM mcr.microsoft.com/dotnet/aspnet:7.0
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "Worker.dll"]