package com.salaboy.echo.workflow;

public class WorkflowPayload {
    private String workflowId;
    private String winner;
    private String option;
	private boolean winnerInTheAudience = false;
	private boolean winnerGotTheBook = false;

	public WorkflowPayload(String workflowId, String winner, String option, boolean winnerInTheAudience,
			boolean winnerGotTheBook) {
		this.workflowId = workflowId;
		this.winner = winner;
		this.option = option;
		this.winnerInTheAudience = winnerInTheAudience;
		this.winnerGotTheBook = winnerGotTheBook;
	}
	
	public WorkflowPayload() {
	}

	public WorkflowPayload(String option) {
		this.option = option;
	}

	public void setWorkflowId(String workflowId) {
		this.workflowId = workflowId;
	}

    public String getWorkflowId(){
        return this.workflowId;
    }

	public String getWinner() {
		return winner;
	}

	public void setWinner(String winner) {
		this.winner = winner;
	}

	public String getOption() {
		return option;
	}

	public void setOption(String option) {
		this.option = option;
	}

	public boolean isWinnerInTheAudience() {
		return winnerInTheAudience;
	}

	public void setWinnerInTheAudience(boolean winnerInTheAudience) {
		this.winnerInTheAudience = winnerInTheAudience;
	}

	public boolean isWinnerGotTheBook() {
		return winnerGotTheBook;
	}

	public void setWinnerGotTheBook(boolean winnerGotTheBook) {
		this.winnerGotTheBook = winnerGotTheBook;
	}

	

}
