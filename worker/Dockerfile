FROM --platform=${BUILDPLATFORM} mcr.microsoft.com/dotnet/sdk:7.0 as build
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"

WORKDIR /source

COPY *.csproj .

RUN case ${TARGETPLATFORM} in \
        "linux/amd64")  ARCH=x64  ;; \
        "linux/arm64")  ARCH=arm64  ;; \
        "linux/arm64/v8")  ARCH=arm64  ;; \
        "linux/arm/v7") ARCH=arm  ;; \
    esac \
    && dotnet restore -r linux-${ARCH} \
    && dotnet add package System.Drawing.Common -v 5.0.3

COPY . .

RUN case ${TARGETPLATFORM} in \
        "linux/amd64")  ARCH=x64  ;; \
        "linux/arm64")  ARCH=arm64  ;; \
        "linux/arm64/v8")  ARCH=arm64  ;; \
        "linux/arm/v7") ARCH=arm  ;; \
    esac \
    && dotnet publish -c release -o /app -r linux-${ARCH} --self-contained false --no-restore --framework net7.0


# app image
FROM mcr.microsoft.com/dotnet/runtime:7.0
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "Worker.dll"]
