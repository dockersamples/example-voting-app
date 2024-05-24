package com.salaboy.result;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.testcontainers.Testcontainers;
import org.testcontainers.containers.Network;
import org.testcontainers.utility.DockerImageName;

import com.redis.testcontainers.RedisContainer;

import io.diagrid.dapr.DaprContainer;
import io.diagrid.dapr.DaprContainer.Component;
import io.diagrid.dapr.DaprContainer.DaprLogLevel;
import io.diagrid.dapr.QuotedBoolean;

@TestConfiguration(proxyBeanMethods = false) 
@ComponentScan("io.dapr.springboot")  
public class DaprTestConfig {

    @Bean
    public DaprContainer getDaprContainer(DynamicPropertyRegistry registry) {


        Testcontainers.exposeHostPorts(8080);

        Network daprNetwork = Network.newNetwork();

        RedisContainer redisContainer = new RedisContainer(DockerImageName.parse("redis/redis-stack"))
                                            .withNetworkAliases("redis")
                                            .withNetwork(daprNetwork);
        redisContainer.start();

        
        Map<String, Object> stateStoreProperties = new HashMap<String, Object>();
        stateStoreProperties.put("keyPrefix", "name");
        stateStoreProperties.put("actorStateStore", new QuotedBoolean("true"));
        stateStoreProperties.put("redisHost", "redis:6379");
        stateStoreProperties.put("redisPassword", "");

        stateStoreProperties.put("queryIndexes", "[{\"name\": \"VotesQueryIndex\",\"indexes\": [{\"key\": \"type\",\"type\": \"TEXT\"}]}]");

        DaprContainer dapr = new DaprContainer("daprio/daprd:1.13.2")
                .withAppName("local-dapr-app")
                .withNetwork(daprNetwork)
                .withComponent(new Component("kvstore", "state.redis", stateStoreProperties ))
                .withComponent(new Component("pubsub", "pubsub.in-memory", Collections.emptyMap() ))
                .withAppPort(8080)
                .withDaprLogLevel(DaprLogLevel.debug)
                .withAppChannelAddress("host.testcontainers.internal");

        registry.add("DAPR_GRPC_ENDPOINT", () -> ("localhost:"+dapr.getGRPCPort()));
        registry.add("DAPR_HTTP_ENDPOINT", dapr::getHttpEndpoint);
        
        dapr.start();


        System.setProperty("dapr.grpc.port", Integer.toString(dapr.getGRPCPort()));
        System.setProperty("dapr.http.port", Integer.toString(dapr.getHTTPPort()));

        System.setProperty("DAPR_GRPC_ENDPOINT", "localhost:"+dapr.getGRPCPort());
        System.setProperty("DAPR_HTTP_ENDPOINT", dapr.getHttpEndpoint());


        System.out.println("Ports: ");
        System.out.println("Ports GRPC: " + Integer.toString(dapr.getGRPCPort()));
        System.out.println("Ports HTTP: " + Integer.toString(dapr.getHTTPPort()));
        
        return dapr;

    }


}
