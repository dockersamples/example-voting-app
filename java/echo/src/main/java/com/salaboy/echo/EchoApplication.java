package com.salaboy.echo;

import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeoutException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import com.salaboy.echo.workflow.PickAWinnerActivity;
import com.salaboy.echo.workflow.PrizeWorkflow;
import com.salaboy.echo.workflow.StoreWinnerActivity;
import com.salaboy.echo.workflow.WorkflowPayload;

import io.dapr.client.domain.CloudEvent;
import io.dapr.Topic;
import io.dapr.workflows.client.DaprWorkflowClient;
import io.dapr.workflows.runtime.WorkflowRuntime;
import io.dapr.workflows.runtime.WorkflowRuntimeBuilder;

@SpringBootApplication
@ConfigurationPropertiesScan
public class EchoApplication {


	public static Map<String, WorkflowPayload> instancePayloads = new ConcurrentHashMap<>();

	public static void main(String[] args) {
		SpringApplication.run(EchoApplication.class, args);
	}

}

@RestController
@RequestMapping("/")
class EchoController {

	private static final Logger logger = LoggerFactory.getLogger(EchoController.class);

	@Value("${PUBLIC_IP:localhost}")
	private String publicIp;

	private final SimpMessagingTemplate simpMessagingTemplate;

	DaprWorkflowClient workflowClient = new DaprWorkflowClient();

	public final static String pubSubName = "pubsub-rabbitmq" ;
    public final static String topicName = "newVote";

	@Topic(name = topicName, pubsubName = pubSubName)
	@PostMapping("events")
	public CloudEvent echo(@RequestBody CloudEvent cloudEvent) {

		logger.info("Echo CloudEvent: " + cloudEvent.toString());
		emitWSEvent(cloudEvent);

		return cloudEvent;
	}

	public EchoController(SimpMessagingTemplate simpMessagingTemplate) {
		this.simpMessagingTemplate = simpMessagingTemplate;
		createWorkflowDefinition();

	}


	@GetMapping("/server-info")
	public Info getInfo() {
		return new Info(publicIp);
	}

	@PostMapping("/pick-a-winner")
	public String pickAWinner(@RequestParam("option") String option) {
		System.out.println(" -> Pick a winner from selected option: " + option);
		return startPrizeWorkflow(option);
	}

	@PostMapping("/yes-winner-in-audience")
	public String yesWinnerInTheAudience(@RequestParam("workflowId") String workflowId) {
		System.out.println(" -> Winner is in the audience: " + workflowId);
		workflowClient.raiseEvent(workflowId, "WinnerInTheAudience", true);
		return "OK";
	}

	@PostMapping("/yes-winner-got-book")
	public String yesWinnerGotBook(@RequestParam("workflowId") String workflowId) {
		System.out.println(" -> Winner got the book: " + workflowId);
		workflowClient.raiseEvent(workflowId, "WinnerGotTheBook", true);
		return "OK";
	}

	@GetMapping("/status")
	public WorkflowPayload getWorkflowStatus(@RequestParam("workflowId") String workflowId){
		return EchoApplication.instancePayloads.get(workflowId);
	}

	public record Info(String publicIp) {
	}

	private void emitWSEvent(CloudEvent event) {
		System.out.println("Emitting Event via WS: " + event.toString());
		simpMessagingTemplate.convertAndSend("/topic/events",
				event);
	}

	private void createWorkflowDefinition(){
		WorkflowRuntimeBuilder builder = new WorkflowRuntimeBuilder().registerWorkflow(PrizeWorkflow.class);
		builder.registerActivity(PickAWinnerActivity.class);
		builder.registerActivity(StoreWinnerActivity.class);
		try (WorkflowRuntime runtime = builder.build()) {
		  System.out.println("Start workflow runtime");
		  runtime.start(false);
		}
	}

	private String startPrizeWorkflow(String option){
		WorkflowPayload payload = new WorkflowPayload(option);
	
		String instanceId = workflowClient.scheduleNewWorkflow(PrizeWorkflow.class, payload);
		System.out.printf("scheduled new workflow instance of PrizeWorkflow with instance ID: %s%n",
			instanceId);
	
		try {
		  workflowClient.waitForInstanceStart(instanceId, Duration.ofSeconds(10), false);
		  System.out.printf("workflow instance %s started%n", instanceId);
		} catch (TimeoutException e) {
		  System.out.printf("workflow instance %s did not start within 10 seconds%n", instanceId);
		}
		return instanceId;
	}

}
