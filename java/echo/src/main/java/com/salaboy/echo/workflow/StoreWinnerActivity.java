package com.salaboy.echo.workflow;

import io.dapr.workflows.runtime.WorkflowActivity;
import io.dapr.workflows.runtime.WorkflowActivityContext;

public class StoreWinnerActivity implements WorkflowActivity{
    
    @Override
    public Object run(WorkflowActivityContext ctx) {
        WorkflowPayload workflowPayload = ctx.getInput(WorkflowPayload.class);
        //Store winner using the Dapr SDKs
        return "";
    }
}
