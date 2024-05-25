package com.salaboy.result;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.salaboy.model.Results;
import com.salaboy.model.Score;

import io.diagrid.springboot.dapr.core.DaprKeyValueTemplate;

@Component
public class FetchResultsJob {

	private DaprKeyValueTemplate keyValueTemplate;

    private SimpMessagingTemplate simpMessagingTemplate;
	

    public FetchResultsJob( DaprKeyValueTemplate keyValueTemplate, SimpMessagingTemplate simpMessagingTemplate) {
		this.simpMessagingTemplate = simpMessagingTemplate;
		this.keyValueTemplate = keyValueTemplate;
		
	}

	@Scheduled(fixedDelay = 2000)
	public void fetchResults() {

		Results results = keyValueTemplate.findById("results", Results.class).get();

		System.out.println("Fetching results: a: "+ results.getOptionA() + " - b: "+ results.getOptionB());

		Score score = new Score(String.valueOf(results.getOptionA()), String.valueOf(results.getOptionB()));
		try{
			simpMessagingTemplate.convertAndSend("/topic/scores",score);
		}catch(Exception e){
			e.printStackTrace();
		}

	}


	  

}
