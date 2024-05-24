package com.salaboy.worker;

import org.springframework.data.annotation.Id;

public class Vote {
    
    @Id
    private String voterId;
    private String option;
    private String type;
    

    public Vote() {
    }

    public Vote(String option, String type, String voterId) {
        this.option = option;
        this.type = type;
        this.voterId = voterId;
    }
    public String getOption() {
        return option;
    }
    public void setOption(String option) {
        this.option = option;
    }
    public String getType() {
        return type;
    }
    public void setType(String type) {
        this.type = type;
    }
    public String getVoterId() {
        return voterId;
    }
    public void setVoterId(String voterId) {
        this.voterId = voterId;
    }

    
}
