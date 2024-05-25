package com.salaboy.result;

//TODO: @thomasvitale why do I need this if this is already provided as part of the core dependency? 

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

import io.dapr.client.DaprClient;
import io.dapr.client.DaprClientBuilder;
import io.dapr.client.DaprPreviewClient;
import io.diagrid.springboot.dapr.core.DaprKeyValueAdapter;
import io.diagrid.springboot.dapr.core.DaprKeyValueTemplate;

@Component
public class DaprConfig {

    @Value("${dapr.query.indexName:QueryIndex}")
    private String queryIndexName;

    @Value("${dapr.statestore.name:kvstore}")
    private String statestoreName;

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


    
}
