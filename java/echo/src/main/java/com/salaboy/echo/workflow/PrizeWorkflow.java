package com.salaboy.echo.workflow;

import io.dapr.workflows.Workflow;
import io.dapr.workflows.WorkflowStub;

import java.time.Duration;

import org.slf4j.Logger;

public class PrizeWorkflow extends Workflow {
  @Override
  public WorkflowStub create() {
    return ctx -> {
      Logger logger = ctx.getLogger();
      String instanceId = ctx.getInstanceId();
      logger.info("Starting Workflow: " + ctx.getName());
      logger.info("Instance ID: " + instanceId);
      logger.info("Current Orchestration Time: " + ctx.getCurrentInstant());

      WorkflowPayload workflowPayload = ctx.getInput(WorkflowPayload.class);
      workflowPayload.setWorkflowId(instanceId);
      
      workflowPayload = ctx.callActivity(PickAWinnerActivity.class.getName(), workflowPayload, WorkflowPayload.class).await();
    
      logger.info("Current Orchestration Time: " + ctx.getCurrentInstant());

      logger.info("A Winner was selected: " + workflowPayload.getWinner());
      logger.info("Let's see if the winner is in the audience!");
      
      boolean winnerIsInTheAudience = ctx.waitForExternalEvent("WinnerInTheAudience", Duration.ofMinutes(5), boolean.class).await();
      logger.info("Is the Winner in the Audience? " + winnerIsInTheAudience);
      if(!winnerIsInTheAudience){
        ctx.complete(workflowPayload);
        return;
      }else{
        workflowPayload.setWinnerInTheAudience(winnerIsInTheAudience);
      }
      logger.info("The winner is in the audience! Let's see if we can deliver the book to the winner!");
      boolean winnerGotTheBook = ctx.waitForExternalEvent("WinnerGotTheBook", Duration.ofMinutes(5), boolean.class).await();
      logger.info("Did the winner got the book? " + winnerIsInTheAudience);
      if(!winnerGotTheBook){
        ctx.complete(workflowPayload);
        return;
      }else{
        workflowPayload.setWinnerGotTheBook(winnerGotTheBook);
      }
      logger.info("The winner got the book copy!");
      logger.info("Let's proceed to store the winner in the hall of fame!");
      workflowPayload = ctx.callActivity(StoreWinnerActivity.class.getName(), workflowPayload, WorkflowPayload.class).await();

      logger.info("The winner is now and forever in the hall of fame!");

      ctx.complete(workflowPayload);

    };
  }
    
}
