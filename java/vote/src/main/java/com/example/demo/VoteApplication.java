package com.example.demo;

import io.dapr.client.DaprClient;
import io.dapr.client.DaprClientBuilder;
import io.dapr.client.domain.SaveStateRequest;
import io.dapr.client.domain.State;
import io.dapr.client.domain.TransactionalStateOperation;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.MultiValueMap;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@SpringBootApplication
@ConfigurationPropertiesScan
public class VoteApplication {

	public static void main(String[] args) {
		SpringApplication.run(VoteApplication.class, args);
	}

}

@ConfigurationProperties(prefix = "vote")
record VoteProperties(String stateStore){}

record Vote(String type, String voterId, String option){}

@Controller
@RequestMapping("/")
class VoteController {

	private static final Logger logger = LoggerFactory.getLogger(VoteController.class);

	private final VoteProperties voteProperties;

	VoteController(VoteProperties voteProperties) {
		this.voteProperties = voteProperties;
	}

	@GetMapping
	String renderHTML(Model model) throws UnknownHostException {
		logger.info("Processing GET request");
		model.addAttribute("option_a", "Cats");
		model.addAttribute("option_b", "Dogs");
		model.addAttribute("hostname", InetAddress.getLocalHost().getHostName());
		model.addAttribute("vote", "");
		return "index.html";
	}

	@PostMapping
	String vote(Model model,
				@RequestBody MultiValueMap<String, String> formData,
				@CookieValue(value = "voter_id", required = false) String voterId,
				HttpServletResponse response
	) throws UnknownHostException {

		logger.info("Processing POST request");

		if (!StringUtils.hasText(voterId)){
			voterId = UUID.randomUUID().toString().substring(0, 10);
		}

		String selectedOption = formData.get("vote").get(0);

		try (DaprClient client = new DaprClientBuilder().build()) {
			Map<String, String> meta = Map.of("contentType", "application/json");
			Vote vote = new Vote("vote", voterId, selectedOption);
			logger.info("A new vote was recorded: " + vote);
			
			List<TransactionalStateOperation<?>> operationList = new ArrayList<>();
			operationList.add(new TransactionalStateOperation<>(TransactionalStateOperation.OperationType.UPSERT,
					new State<>("voter-"+vote.voterId(), vote, null, meta, null)));
	
            //Using Dapr SDK to perform the state transactions
			client.executeStateTransaction(voteProperties.stateStore(), operationList).block();

			// SaveStateRequest request = new SaveStateRequest(voteProperties.stateStore())
			//  		.setStates(new State<>("voter-"+vote.voterId(), vote, null, meta, null));

			// client.saveBulkState(request).block();
			
		} catch (Exception ex) {
			logger.error("An error occurred while trying to save the vote.", ex);
		}

		response.addCookie(new Cookie("voter_id", voterId));

		model.addAttribute("option_a", "Cats");
		model.addAttribute("option_b", "Dogs");
		model.addAttribute("hostname", InetAddress.getLocalHost().getHostName());
		model.addAttribute("vote", selectedOption);
		return "index.html";
	}

}
