# Stage 1: Build the application
FROM --platform=${BUILDPLATFORM} mcr.microsoft.com/dotnet/sdk:7.0 AS build
ARG TARGETPLATFORM
ARG TARGETARCH
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"

WORKDIR /source
COPY *.csproj .
RUN dotnet restore -a $TARGETARCH

COPY . .
RUN dotnet publish -c release -o /app -a $TARGETARCH --self-contained false --no-restore

# Stage 2: Install OpenTelemetry .NET auto-instrumentation
FROM mcr.microsoft.com/dotnet/runtime:7.0 AS otel
WORKDIR /otel
RUN apt-get update && apt-get install -y \
curl unzip

RUN curl -sSfL https://github.com/open-telemetry/opentelemetry-dotnet-instrumentation/releases/latest/download/otel-dotnet-auto-install.sh -O && \
    sh ./otel-dotnet-auto-install.sh && \
    chmod +x /root/.otel-dotnet-auto/instrument.sh

# Stage 3: Build the final app image
FROM mcr.microsoft.com/dotnet/runtime:7.0
WORKDIR /app

# Copy the published application from the build stage
COPY --from=build /app .

# Copy the OpenTelemetry instrumentation from the otel stage
COPY --from=otel /root/.otel-dotnet-auto /root/.otel-dotnet-auto

# Set environment variables for OpenTelemetry
ENV OTEL_TRACES_EXPORTER=otlp \
    OTEL_METRICS_EXPORTER=otlp \
    OTEL_LOGS_EXPORTER=otlp \
    OTEL_EXPORTER_OTLP_ENDPOINT=http://141.148.199.176:4318 \
    OTEL_SERVICE_NAME=DotNetWorker

# Source the OpenTelemetry instrumentation script
RUN . $HOME/.otel-dotnet-auto/instrument.sh

# Set the entrypoint to run the application with OpenTelemetry instrumentation
ENTRYPOINT ["dotnet", "Worker.dll"]

