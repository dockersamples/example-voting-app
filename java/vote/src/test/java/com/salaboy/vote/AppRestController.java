package com.salaboy.vote;

import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import io.dapr.Topic;
import io.dapr.client.domain.CloudEvent;

@RestController
public class AppRestController {

    private static final Logger LOG = LoggerFactory.getLogger(AppRestController.class);

    public static final String pubSubName = "pubsub";
    public static final String topicName = "votes";

    private List<CloudEvent> events = new ArrayList<>();

    @Topic(name = topicName, pubsubName = pubSubName)
    @PostMapping("/subscribe")
    public void handleMessages(@RequestBody CloudEvent<Vote> event) {
        LOG.info("++++++CONSUME {}------", event);
        events.add(event);
    }

    public List<CloudEvent> getEvents() {
        return events;
    }
}
