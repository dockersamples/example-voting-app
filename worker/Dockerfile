FROM maven:3.8.5-jdk-11-slim 
WORKDIR /app 
COPY . .
RUN mvn package && \ 
    mv target/worker-jar-with-dependencies.jar /run/worker.jar &&\        
    rm -rf /app/*
CMD java -jar /run/worker.jar
