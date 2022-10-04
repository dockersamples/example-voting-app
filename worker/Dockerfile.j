FROM --platform=$BUILDPLATFORM maven:3.8.6-eclipse-temurin-19-focal AS build

WORKDIR /code

COPY pom.xml /code/pom.xml
RUN ["mvn", "dependency:resolve"]
RUN ["mvn", "verify"]

# Adding source, compile and package into a fat jar
COPY ["src/main", "/code/src/main"]
RUN ["mvn", "package"]

FROM eclipse-temurin:19_36-jre-jammy

COPY --from=build /code/target/worker-jar-with-dependencies.jar /

CMD ["java", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-jar", "/worker-jar-with-dependencies.jar"]
