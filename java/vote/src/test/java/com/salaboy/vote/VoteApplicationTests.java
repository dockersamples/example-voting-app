package com.salaboy.vote;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.util.Collections;
import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.context.TestPropertySource;
import org.springframework.ui.ExtendedModelMap;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;

import io.dapr.client.domain.CloudEvent;

@SpringBootTest(classes={DaprTestConfig.class}, webEnvironment = WebEnvironment.DEFINED_PORT)
@ComponentScan("com.salaboy.vote")
@ComponentScan("io.dapr.springboot")
@TestPropertySource(properties = {
    "vote.pubsub=pubsub",
	"vote.topic=votes"
})
class VoteApplicationTests {

	@Autowired
	private VoteController voteController;

	@Autowired
	private AppRestController appRestController;

	@Test
    public void testVote() throws InterruptedException {
		ExtendedModelMap extendedModelMap = new ExtendedModelMap();
		MultiValueMap<String, String> formData = new LinkedMultiValueMap<>();
		formData.put("vote", Collections.singletonList("a"));
		MockHttpServletResponse response = new MockHttpServletResponse();
		
		voteController.vote(extendedModelMap, formData, UUID.randomUUID().toString().substring(0, 10), response);

		assertEquals(1, response.getCookies().length);


		List<CloudEvent> events = appRestController.getEvents();

		assertTrue(!events.isEmpty() );
	}


	

}
