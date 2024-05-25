package com.salaboy.result;

import static org.mockito.Mockito.atLeast;
import static org.mockito.Mockito.verify;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.mock.mockito.SpyBean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.DependsOn;
import org.springframework.test.context.TestPropertySource;

import com.salaboy.model.Results;

import io.diagrid.springboot.dapr.core.DaprKeyValueTemplate;

import org.awaitility.Duration;
import static org.awaitility.Awaitility.await;

@SpringBootTest(classes={DaprTestConfig.class}, webEnvironment = WebEnvironment.RANDOM_PORT)
@ComponentScan("com.salaboy.result")
@ComponentScan("io.dapr.springboot")
@DependsOn("keyValueTemplate")
@TestPropertySource(properties = {
    "dapr.query.indexName=VotesQueryIndex",
})
public class ResultTest {
    
    @Autowired
	@Qualifier("keyValueTemplate")
	DaprKeyValueTemplate keyValueTemplate;

    @SpyBean
    FetchResultsJob fetchResultsJob;

    @Test
    public void testResultJob() throws InterruptedException {

        Results results = new Results(3, 5);
        keyValueTemplate.insert("results", results);
     
        Thread.sleep(5000);

        await()
          .atMost(Duration.FIVE_SECONDS)
          .untilAsserted(() -> verify(fetchResultsJob, atLeast(2)).fetchResults());

        Thread.sleep(5000);
        
        
    }
}
