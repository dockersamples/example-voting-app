package com.salaboy.echo.workflow;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.dapr.workflows.runtime.WorkflowActivity;
import io.dapr.workflows.runtime.WorkflowActivityContext;

public class PickAWinnerActivity implements WorkflowActivity {


    private static RestTemplate restTemplate;
    
    @Override
    public Object run(WorkflowActivityContext ctx) {
        WorkflowPayload workflowPayload = ctx.getInput(WorkflowPayload.class);

        String daprHttp = System.getenv("DAPR_HTTP_ENDPOINT");
        String stateStore = System.getenv("ECHO_STATE_STORE");
        if(daprHttp == null || daprHttp.isEmpty()){
            daprHttp = "http://localhost:3500";
        }
        restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Type", "application/json");
        headers.add("dapr-app-id", "echo");
        headers.add("dapr-api-token", System.getenv("DAPR_API_TOKEN"));

        System.out.println("WorkflowPayload: " + workflowPayload);
        System.out.println("Query URL: " + daprHttp + "/v1.0-alpha1/state/"+stateStore+"/query?metadata.contentType=application/json&metadata.queryIndexName=voteIndex");

        PropertyFilter voteFilter = new EQVote("vote");
        PropertyFilter optionFilter = new EQOption(workflowPayload.getOption());
        
        List<EQ> AND = new ArrayList<>();
        AND.add(new EQ(optionFilter));
        AND.add(new EQ(voteFilter));
        DaprFilter filter = new DaprFilter(new Filter(AND), 
            Collections.singletonList(new Sort("type", Order.DESC)));
        HttpEntity<DaprFilter> request = new HttpEntity<DaprFilter>(
            filter, 
            headers);
            
        Results response = restTemplate.postForObject(
            daprHttp + "/v1.0-alpha1/state/"+stateStore+"/query?metadata.contentType=application/json&metadata.queryIndexName=voteIndex", 
            request, Results.class);

        System.out.println("Response: " + response.toString());

        //Filter by option
        List<Vote> votesForOption = new ArrayList<>();
        for(Data data : response.data()){
            System.out.println("Vote - Voter Id: " + data.vote.voterId);
            if(data.vote.option.equals(workflowPayload.getOption())){
                votesForOption.add(data.vote);
            }
        }

        Random rand = new Random();
        Vote winnerVote = votesForOption.get(rand.nextInt(votesForOption.size()));
     
        System.out.println("And the WINNER IS!!! Voter Id: " + winnerVote.voterId);

        workflowPayload.setWinner(winnerVote.voterId);
     
        return workflowPayload;
    } 

    public record DaprFilter(@JsonProperty("filter") Filter filter, @JsonProperty("sort") List<Sort> sort){}

    public record Filter(@JsonProperty("AND") List<EQ> eqs){}
    public record EQ(@JsonProperty("EQ") PropertyFilter filter){}
    public record EQVote(@JsonProperty("type") String type) implements PropertyFilter{}
    public record EQOption(@JsonProperty("option") String option) implements PropertyFilter{}

    public record Sort(@JsonProperty("key") String key, @JsonProperty("order") Order order){}

    public enum Order{ ASC, DESC }

    public interface PropertyFilter{}

    /// {"results":[{"key":"voter-cd7a901c-1","data":{"type":"vote","voterId":"cd7a901c-1","option":"b","user":"cd7a901c-1"},"etag":"1"},{"key":"voter-28d9c909-0","data":{"user":"28d9c909-0","type":"vote","voterId":"28d9c909-0","option":"a"},"etag":"6"}]}

    

    public record Results(@JsonProperty("results") List<Data> data){}

    public record Data(@JsonProperty("data") Vote vote){}
    
    public record Vote(@JsonProperty("option") String option, @JsonProperty("voterId") String voterId, @JsonProperty("type") String type){}

}
