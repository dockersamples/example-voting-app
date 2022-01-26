FROM maven:3.8.4-openjdk-17 AS build

WORKDIR /usr/src/app/
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn dependency:copy-dependencies
COPY src ./src/
RUN --mount=type=cache,target=/root/.m2 mvn package

FROM openjdk:17-alpine3.14

RUN apk update && \
    apk add --no-cache su-exec && \
    addgroup -S worker && adduser -S worker -G worker

ARG TARGET_DIR=/usr/src/app/target
COPY --from=build ${TARGET_DIR}/dependency /app/lib
COPY --from=build ${TARGET_DIR}/classes /app

EXPOSE 8080

CMD ["su-exec","worker:worker","java","-cp","app:app/lib/*","worker.Worker"]
