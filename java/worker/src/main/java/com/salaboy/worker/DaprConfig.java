package com.salaboy.worker;

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

    @Value("${votes.statestore.name:kvstore}")
    private String votesStatestoreName;

    @Value("${results.statestore.name:kvstore}")
    private String resultsStatestoreName;

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
	public DaprKeyValueTemplate votesKeyValueTemplate(DaprClient daprClient, DaprPreviewClient daprPreviewClient) {
		return new DaprKeyValueTemplate(votesKeyValueAdapter(daprClient, daprPreviewClient));
	}

    @Bean
	public DaprKeyValueTemplate resultsKeyValueTemplate(DaprClient daprClient, DaprPreviewClient daprPreviewClient) {
		return new DaprKeyValueTemplate(resultsKeyValueAdapter(daprClient, daprPreviewClient));
	}

	@Bean
	public DaprKeyValueAdapter votesKeyValueAdapter(DaprClient daprClient, DaprPreviewClient daprPreviewClient) {
		return new DaprKeyValueAdapter(daprClient, daprPreviewClient, votesStatestoreName, queryIndexName);
	}

    @Bean
	public DaprKeyValueAdapter resultsKeyValueAdapter(DaprClient daprClient, DaprPreviewClient daprPreviewClient) {
		return new DaprKeyValueAdapter(daprClient, daprPreviewClient, resultsStatestoreName, queryIndexName);
	}

}
