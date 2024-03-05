FROM docker.io/library/eclipse-temurin:21-jdk-jammy AS builder
WORKDIR workspace
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
RUN java -Djarmode=layertools -jar app.jar extract

FROM docker.io/library/eclipse-temurin:21-jre-jammy
RUN useradd spring
USER spring
WORKDIR workspace
COPY --from=builder workspace/dependencies/ ./
COPY --from=builder workspace/spring-boot-loader/ ./
COPY --from=builder workspace/snapshot-dependencies/ ./
COPY --from=builder workspace/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]