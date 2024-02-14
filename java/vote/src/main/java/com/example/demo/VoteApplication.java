package com.example.demo;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import io.dapr.client.DaprClient;
import io.dapr.client.DaprClientBuilder;
import io.dapr.client.domain.SaveStateRequest;
import io.dapr.client.domain.State;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;

@SpringBootApplication
@Controller
public class VoteApplication {

	@Value("${VOTE_STATESTORE:votes-statestore}")
	private String STATESTORE_NAME;
	public record Vote(String type, String voterId, String option){}

	public static void main(String[] args) {
		SpringApplication.run(VoteApplication.class, args);
	}

	@RequestMapping(value = "/", method = RequestMethod.GET)
	public String renderHTML(Model model) throws UnknownHostException {
		System.out.println("GET");
		model.addAttribute("option_a", "Cats");
		model.addAttribute("option_b", "Dogs");
		model.addAttribute("hostname", InetAddress.getLocalHost().getHostName());
		model.addAttribute("vote", "");
		return "index.html";
	}

	@RequestMapping(value = "/", method = RequestMethod.POST)
	public String vote(Model model, @RequestBody MultiValueMap<String, String> formData, @CookieValue(value = "voter_id", required = false) String voterId, HttpServletResponse response) throws UnknownHostException {
		
		if (voterId == null || voterId.equals("")){
			voterId = UUID.randomUUID().toString().substring(0, 10);
		}
		String selectedOption = formData.get("vote").get(0);
		try (DaprClient client = (new DaprClientBuilder()).build()) {
			 Map<String, String> meta = new HashMap<>();
        	meta.put("contentType", "application/json");
			
			Vote vote = new Vote("vote", voterId, selectedOption);
			System.out.println("A new vote was recorded: " + vote);

			SaveStateRequest request = new SaveStateRequest(STATESTORE_NAME)
									.setStates(new State<>("voter-"+vote.voterId, vote, null, meta, null));
			
			client.saveBulkState(request).block();

		} catch (Exception ex) {
			ex.printStackTrace();
		}

		response.addCookie(new Cookie("voter_id", voterId));

		model.addAttribute("option_a", "Cats");
		model.addAttribute("option_b", "Dogs");
		model.addAttribute("hostname", InetAddress.getLocalHost().getHostName());
		model.addAttribute("vote", selectedOption);
		return "index.html";
	}

}
