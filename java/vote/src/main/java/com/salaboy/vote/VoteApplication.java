package com.salaboy.vote;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.MultiValueMap;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import io.diagrid.springboot.dapr.core.DaprKeyValueTemplate;
import io.diagrid.springboot.dapr.core.DaprMessagingTemplate;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.UUID;
import com.salaboy.model.Vote;

@SpringBootApplication
@ConfigurationPropertiesScan
@ComponentScan("io.dapr.springboot")
@ComponentScan("com.salaboy.vote")
public class VoteApplication {

	public static void main(String[] args) {
		SpringApplication.run(VoteApplication.class, args);
	}

}

@ConfigurationProperties(prefix = "vote")
record VoteProperties(String stateStore, String pubsub, String topic){}

@Controller
@RequestMapping("/")
class VoteController {

	private static final Logger logger = LoggerFactory.getLogger(VoteController.class);

	private final VoteProperties voteProperties;

	private final DaprKeyValueTemplate keyValueTemplate;

	private final DaprMessagingTemplate<Vote> messagingTemplate;

	VoteController(VoteProperties voteProperties, DaprKeyValueTemplate keyValueTemplate, DaprMessagingTemplate<Vote> messagingTemplate) {
		this.keyValueTemplate = keyValueTemplate;
		this.messagingTemplate = messagingTemplate;
		this.voteProperties = voteProperties;
	}

	@GetMapping
	String renderHTML(Model model, @CookieValue(value = "voter_id", required = false) String voterId) throws UnknownHostException {
		logger.info("Processing GET request");
		model.addAttribute("option_a", "Cats");
		model.addAttribute("option_b", "Dogs");
		model.addAttribute("hostname", InetAddress.getLocalHost().getHostName());
		model.addAttribute("vote", "");
		model.addAttribute("user", voterId);
		return "index.html";
	}

	@PostMapping
	String vote(Model model,
				@RequestBody MultiValueMap<String, String> formData,
				@CookieValue(value = "voter_id", required = false) String voterId,
				HttpServletResponse response
	) {

		logger.info("Processing POST request");

		if (!StringUtils.hasText(voterId)){
			voterId = UUID.randomUUID().toString().substring(0, 10);
		}

		String selectedOption = formData.get("vote").get(0);

		Vote vote = new Vote("vote", voterId, selectedOption, voterId);
		
		// Upsert (insert or update) the vote
		keyValueTemplate.update(vote);

		if (voteProperties.pubsub() != null && !voteProperties.pubsub().equals("")){
			// Emit CloudEvent
			System.out.println("Emitting Cloud Event to Pubsub: " + voteProperties.pubsub() + "and topic: " + voteProperties.topic());
			messagingTemplate.send(voteProperties.topic(), vote);
		}


		// try (DaprClient client = new DaprClientBuilder().build()) {
		// 	Map<String, String> meta = Map.of("contentType", "application/json");
		// 	Vote vote = new Vote("vote", voterId, selectedOption, voterId);
		// 	logger.info("A new vote was recorded: " + vote + "into the state store:" + voteProperties.stateStore() );
			
		// 	// There is a bug in the runtime that is blocking this to work with JSON Encoding: https://github.com/dapr/dapr/issues/7580
		// 	// List<TransactionalStateOperation<?>> operationList = new ArrayList<>();
		// 	// operationList.add(new TransactionalStateOperation<>(TransactionalStateOperation.OperationType.UPSERT,
		// 	// 		new State<>("voter-"+vote.voterId(), vote, null, meta, null)));
	
        //     // //Using Dapr SDK to perform the state transactions
		// 	// client.executeStateTransaction(voteProperties.stateStore(), operationList).block();

		// 	SaveStateRequest request = new SaveStateRequest(voteProperties.stateStore())
		// 	 		.setStates(new State<>("voter-"+vote.voterId(), vote, null, meta, null));

		// 	client.saveBulkState(request).block();

		// 	if (voteProperties.pubsub() != null && !voteProperties.pubsub().equals("")){
		// 		logger.info("Emitting vote event via code: " + vote + "into the pubsubs: " 
		// 						+ voteProperties.pubsub() + " and topic: " + voteProperties.topic());
		// 		client.publishEvent(voteProperties.pubsub(), voteProperties.topic(), vote).block();
		// 	}
			
		// } catch (Exception ex) {
		// 	logger.error("An error occurred while trying to save the vote.", ex);
		// }

		response.addCookie(new Cookie("voter_id", voterId));
		
		String hostName = "";
		try {
			hostName = InetAddress.getLocalHost().getHostName();
		} catch (UnknownHostException e) {
			e.printStackTrace();
		}
		
		model.addAttribute("option_a", "Cats");
		model.addAttribute("option_b", "Dogs");
		model.addAttribute("hostname", hostName);
		model.addAttribute("vote", selectedOption);
		model.addAttribute("user", voterId);
		return "index.html";
	}


}
