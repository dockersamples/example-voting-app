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
    
      boolean winnerIsInTheAudience = ctx.waitForExternalEvent("WinnerInTheAudience", Duration.ofMinutes(5), boolean.class).await();

      if(!winnerIsInTheAudience){
        ctx.complete(workflowPayload);
        return;
      }else{
        workflowPayload.setWinnerInTheAudience(winnerIsInTheAudience);
      }

      boolean winnerGotTheBook = ctx.waitForExternalEvent("WinnerGotTheBook", Duration.ofMinutes(5), boolean.class).await();
      
      if(!winnerGotTheBook){
        ctx.complete(workflowPayload);
        return;
      }else{
        workflowPayload.setWinnerGotTheBook(winnerGotTheBook);
      }

      workflowPayload = ctx.callActivity(StoreWinnerActivity.class.getName(), workflowPayload, WorkflowPayload.class).await();

      ctx.complete(workflowPayload);

    };
  }
    
}
