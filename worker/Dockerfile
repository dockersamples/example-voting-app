
# Build stage
FROM --platform=${BUILDPLATFORM} mcr.microsoft.com/dotnet/sdk:7.0 AS build

ARG TARGETPLATFORM
ARG TARGETARCH
ARG BUILDPLATFORM

RUN echo "Building on $BUILDPLATFORM for $TARGETPLATFORM"

WORKDIR /source

COPY *.csproj .
RUN dotnet restore -a $TARGETARCH

COPY . .
RUN dotnet publish -c Release -o /app -a $TARGETARCH \
    --self-contained false --no-restore

# Runtime stage
FROM mcr.microsoft.com/dotnet/runtime:7.0

WORKDIR /app

# Create a dedicated non-root account
RUN groupadd --system app && \
    useradd --system --gid app --home-dir /home/app --create-home app

COPY --from=build --chown=app:app /app .

USER app

ENTRYPOINT ["dotnet", "Worker.dll"]
