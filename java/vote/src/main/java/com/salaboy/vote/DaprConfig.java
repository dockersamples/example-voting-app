package com.salaboy.vote;

//TODO: @thomasvitale why do I need this if this is already provided as part of the core dependency? 

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

import io.dapr.client.DaprClient;
import io.dapr.client.DaprClientBuilder;
import io.dapr.client.DaprPreviewClient;
import io.diagrid.springboot.dapr.core.DaprKeyValueAdapter;
import io.diagrid.springboot.dapr.core.DaprKeyValueTemplate;
import io.diagrid.springboot.dapr.core.DaprMessagingTemplate;
import com.salaboy.model.Vote;

@Component
public class DaprConfig {

    @Value("${dapr.query.indexName:QueryIndex}")
    private String queryIndexName;


    @Value("${dapr.statestore.name:kvstore}")
    private String statestoreName;

    @Value("${dapr.pubsub.name:pubsub}")
    private String pubsubName;

    private DaprClientBuilder builder = new DaprClientBuilder();

    @Bean
    public DaprClient daprClient(){
        return builder.build();
    }

    @Bean
    public DaprPreviewClient daprPreviewClient(){
        return builder.buildPreviewClient();
    }

    @Bean
	public DaprKeyValueTemplate keyValueTemplate(DaprClient daprClient, DaprPreviewClient daprPreviewClient) {
		return new DaprKeyValueTemplate(keyValueAdapter(daprClient, daprPreviewClient));
	}

	@Bean
	public DaprKeyValueAdapter keyValueAdapter(DaprClient daprClient, DaprPreviewClient daprPreviewClient) {
		return new DaprKeyValueAdapter(daprClient, daprPreviewClient, statestoreName, queryIndexName);
	}

    @Bean
	public DaprMessagingTemplate<Vote> messagingTemplate(DaprClient daprClient){
		return new DaprMessagingTemplate<Vote>(daprClient, pubsubName);
	}
    
}
